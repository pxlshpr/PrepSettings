import SwiftUI
import OSLog
import HealthKit
import CoreData

import PrepShared

public typealias FetchCurrentHealthHandler = (() async throws -> Health)
public typealias SaveHealthHandler = ((Health, Bool) async throws -> ())

@Observable public class HealthModel {

    public let isCurrent: Bool
    public var ignoreChanges: Bool = false
    
    internal let logger = Logger(subsystem: "HealthModel", category: "")
    internal var handleChangesTask: Task<Void, Error>? = nil
    
//    let fetchCurrentHealthHandler: FetchCurrentHealthHandler?
//    let saveHandler: SaveHealthHandler
    let delegate: HealthModelDelegate
    
    public var health: Health {
        didSet {
            guard !ignoreChanges else { return }
            handleChanges(from: oldValue)
        }
    }
    
    var typesBeingSetFromHealthKit: [HealthType] = []

    /// Current Health
    public init(
        delegate: HealthModelDelegate,
        fetchCurrentHealthHandler: @escaping FetchCurrentHealthHandler
//        saveHandler: @escaping SaveHealthHandler
    ) {
//        self.fetchCurrentHealthHandler = fetchCurrentHealthHandler
//        self.saveHandler = saveHandler
        self.delegate = delegate
        self.health = Health()
        self.isCurrent = true
        loadCurrentHealth(fetchCurrentHealthHandler)
    }
    
    /// Past Health
    public init(
        delegate: HealthModelDelegate,
        health: Health
//        saveHandler: @escaping SaveHealthHandler
    ) {
//        self.fetchCurrentHealthHandler = nil
//        self.saveHandler = saveHandler
        self.delegate = delegate
        self.health = health
        self.isCurrent = false
    }

    public func loadCurrentHealth(_ handler: @escaping FetchCurrentHealthHandler) {
        Task {
            let health = try await handler()
            await MainActor.run {
                /// Ignoring changes so that we don't trigger permissions and health fetches implicitly (we should do it explicitly at the right time, and not when loading this)
                ignoreChanges = true
                self.health = health
                ignoreChanges = false
                post(.didLoadCurrentHealth)
            }
        }
    }
}

public extension HealthModel {

    func updateHealthValues() async throws {
        /// Set the model to ignore changes so that it doesn't redudantly fetch health twice (in `handleChanges`)
        ignoreChanges = true

        try await setFromHealthKit()

        /// Now turn off this flag so that manual user changes are handled appropriately
        ignoreChanges = false
    }
}
