import SwiftUI
import PrepShared

public extension HealthModel {
    
    func handleChanges(from old: HealthDetails) {
        guard !old.matches(health) else {
            logger.debug("Health set but did not change, ignoring")
            return
        }
        
        /// Use this for debugging as `self.health` isn't always printable
//        let new = health

        logger.debug("Health changed, updating and saving")
        handleChangesTask?.cancel()
        handleChangesTask = Task {
            do {
                try await handleChanges(from: old)
                try Task.checkCancellation()
                try await saveHealth()
            } catch is CancellationError {
                /// Task cancelled
                logger.debug("Task was cancelled")
            } catch {
                logger.error("Error updating health: \(error.localizedDescription)")
            }
        }
    }
    
    func saveHealth() async throws {
        try await delegate.saveHealth(health, isCurrent: isCurrent)
//        try await saveHandler(health, isCurrent)
    }
    
    /// This is supposed to handle single changes only (eg. when we change the weight source), and not multiple different changes
    func handleChanges(from old: HealthDetails) async throws {
        
//        typesBeingSetFromHealthKit = []
        
        /// Get the first type that has changed from a non-HealthKit source to HealthKit
        if let type = health.typeToFetchFromHealthKit(from: old) {
            try await setTypeFromHealthKit(type)
        }
        
        await MainActor.run {
            health.recalculate()
        }
    }

    func valueIsNil(for type: HealthType) -> Bool {
        health.valueIsNil(for: type)
    }
    
    func setFromHealthKit() async throws {
        
        try await withThrowingTaskGroup(of: Void.self) { taskGroup in
            for type in HealthType.healthKitTypes {
                if health.sourceIsHealthKit(for: type) {
                    taskGroup.addTask { try await self.setTypeFromHealthKit(type) }
                }
            }
            while let _ = try await taskGroup.next() { }
        }
        
        await MainActor.run {
            health.recalculate()
        }
    }
}

public extension HealthType {
    static var healthKitTypes: [HealthType] {
        allCases.filter { $0.supportsHealthKit }
    }
    
    var supportsHealthKit: Bool {
        switch self {
        case .maintenance, .fatPercentage, .pregnancyStatus, .isSmoker:
            false
        default:
            true
        }
    }
}

extension HealthDetails {
    
    func sourceIsHealthKit(for type: HealthType) -> Bool {
        switch type {
        case .weight:           weight?.source == .healthKit
        case .height:           heightSource == .healthKit
        case .age:              ageSource == .healthKit
        case .sex:              sexSource == .healthKit
        case .leanBodyMass:     leanBodyMassSource == .healthKit
        case .activeEnergy:     activeEnergySource == .healthKit
        case .restingEnergy:    restingEnergySource == .healthKit
        default:                false
        }
    }
    
    func valueIsNil(for type: HealthType) -> Bool {
        switch type {
        case .weight:               weight?.valueInKg == nil
        case .height:               height?.quantity == nil
        case .age:                  age?.value == nil
        case .sex:                  sex?.value == nil
        case .leanBodyMass:         leanBodyMass?.quantity == nil
        case .activeEnergy:         activeEnergy?.value == nil
        case .restingEnergy:        restingEnergy?.value == nil
        case .maintenance:    estimatedMaintenanceInKcal == nil
        case .pregnancyStatus:      pregnancyStatus == nil
        case .isSmoker:             isSmoker == nil
        case .fatPercentage:        fatPercentage == nil
        }
    }
}
