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
    
    /// Past Health
    public init(
        delegate: HealthModelDelegate,
        health: HealthDetails
//        saveHandler: @escaping SaveHealthHandler
    ) {
//        self.fetchCurrentHealthHandler = nil
//        self.saveHandler = saveHandler
        self.delegate = delegate
        self.health = health
        self.isCurrent = false
        self.isEditing = false
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
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didUpdateWeight),
            name: .didUpdateWeight,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didRemoveWeight),
            name: .didRemoveWeight,
            object: nil
        )
    }
    
    @objc func didUpdateWeight(notification: Notification) {
//        guard let date = notification.date,
//              let healthQuantity = notification.weightHealthQuantity,
//              health.date == date
//        else {
//            return
//        }
//        
//        health.weight = healthQuantity
        //TODO: Handle re-calculating stuff in Health?
    }
    
    @objc func didRemoveWeight(notification: Notification) {
//        guard let date = notification.date,
//              health.date == date,
//              health.weight?.source == .userEntered
//        else {
//            return
//        }
//        
//        health.weight = nil
        //TODO: Handle re-calculating stuff in Health?
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
