import SwiftUI
import OSLog
import HealthKit
import CoreData

import PrepShared

@Observable public class HealthModel {

    public let isCurrent: Bool
    public var ignoreChanges: Bool = false
    
    internal let logger = Logger(subsystem: "HealthModel", category: "")
    internal var handleChangesTask: Task<Void, Error>? = nil
    
    var fetchCurrentHealthHandler: (() async throws -> Health)? = nil
    var saveHandler: ((Health, Bool) async throws -> ())
    
    public var health: Health {
        didSet {
            guard !ignoreChanges else { return }
            handleChanges(from: oldValue)
        }
    }
    
    var typesBeingSetFromHealthKit: [HealthType] = []

    /// Current Health
    public init(
        fetchCurrentHealthHandler: (@escaping () async throws -> Health),
        saveHandler: (@escaping (Health, Bool) async throws -> ())
    ) {
        self.fetchCurrentHealthHandler = fetchCurrentHealthHandler
        self.saveHandler = saveHandler
        self.health = Health()
        self.isCurrent = true
        loadCurrentHealth(fetchCurrentHealthHandler)
    }
    
    /// Past Health
    public init(
        health: Health,
        saveHandler: (@escaping (Health, Bool) async throws -> ())
    ) {
        self.fetchCurrentHealthHandler = nil
        self.saveHandler = saveHandler
        self.health = health
        self.isCurrent = false
    }

    public func loadCurrentHealth(_ handler: @escaping (() async throws -> Health)) {
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
