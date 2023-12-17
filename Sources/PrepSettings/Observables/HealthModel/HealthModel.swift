import SwiftUI
import OSLog
import HealthKit
import CoreData
import PrepShared

public typealias FetchCurrentHealthHandler = (() async throws -> HealthDetails)
public typealias SaveHealthHandler = ((HealthDetails, Bool) async throws -> ())

@Observable public class HealthModel {

    public let isCurrent: Bool
    public var isEditing: Bool
    public var ignoreChanges: Bool = false
    
    internal let logger = Logger(subsystem: "HealthModel", category: "")
    internal var handleChangesTask: Task<Void, Error>? = nil
    
//    let fetchCurrentHealthHandler: FetchCurrentHealthHandler?
//    let saveHandler: SaveHealthHandler
    let delegate: HealthModelDelegate
    
    public var health: HealthDetails {
        didSet {
            guard !ignoreChanges else {
                return
            }
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
        self.health = HealthDetails()
        self.isCurrent = true
        self.isEditing = true
        loadCurrentHealth(fetchCurrentHealthHandler)
        addObservers()
    }
    
    /// Past or Current Health
    public init(
        delegate: HealthModelDelegate,
        health: HealthDetails,
        isCurrent: Bool = false
//        saveHandler: @escaping SaveHealthHandler
    ) {
//        self.fetchCurrentHealthHandler = nil
//        self.saveHandler = saveHandler
        self.delegate = delegate
        self.health = health
        self.isCurrent = isCurrent
        self.isEditing = isCurrent
        addObservers()
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

extension HealthModel {
    func addObservers() {
    }
}
