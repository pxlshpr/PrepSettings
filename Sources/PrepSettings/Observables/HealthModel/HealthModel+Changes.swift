import SwiftUI
import PrepShared

public extension HealthModel {
    
    func handleChanges(from old: Health) {
        guard !old.matches(health) else {
            logger.debug("Health set but did not change, ignoring")
            return
        }
        
        /// Use this for debugging as `self.health` isn't always printable
//        let new = health

        logger.debug("Health changed, updating and saving")

        saveHealthTask?.cancel()
        saveHealthTask = Task {
            do {
                try await handleChanges(from: old)
                try Task.checkCancellation()
                try await saveHandler(health, isCurrent)
            } catch is CancellationError {
                /// Task cancelled
                logger.debug("Task was cancelled")
            } catch {
                logger.error("Error updating health: \(error.localizedDescription)")
            }
        }
    }
    
    /// This is supposed to handle single changes only (eg. when we change the weight source), and not multiple different changes
    func handleChanges(from old: Health) async throws {
        
        /// Get the first type that has changed from a non-HealthKit source to HealthKit
        guard let type = health.typeToFetchFromHealthKit(from: old) else { return }

        try await setTypeFromHealthKit(type)
        
        await MainActor.run {
            health.recalculate()
        }
    }
    
//    func handleChanges(from old: Health) async throws {
//        
//        /// Request for permissions
//        let quantityTypes = health.quantityTypesToSync(from: old)
//        let characteristicTypeIdentifiers = health.characteristicTypesToSync(from: old)
//        if !quantityTypes.isEmpty || !characteristicTypeIdentifiers.isEmpty {
//            if !isPreview {
//                try await HealthStore.requestPermissions(
//                    characteristicTypeIdentifiers: characteristicTypeIdentifiers,
//                    quantityTypes: quantityTypes
//                )
//                try Task.checkCancellation()
//            }
//        }
//        
//        /// Trigger HealthKit syncs for any that were turned on
//        if quantityTypes.contains(.weight) {
//            try await setWeightFromHealthKit()
//            try Task.checkCancellation()
//        }
//        if quantityTypes.contains(.leanBodyMass) {
//            try await setLeanBodyMassFromHealthKit()
//            try Task.checkCancellation()
//        }
//        if quantityTypes.contains(.height) {
//            try await setHeightFromHealthKit()
//            try Task.checkCancellation()
//        }
//        if characteristicTypeIdentifiers.contains(.sex) {
//            try await setSexFromHealthKit()
//            try Task.checkCancellation()
//        }
//        if characteristicTypeIdentifiers.contains(.dateOfBirth) {
//            try await setAgeFromHealthKit()
//            try Task.checkCancellation()
//        }
//        if quantityTypes.contains(.restingEnergy) {
//            try await setRestingEnergyFromHealthKit()
//            try Task.checkCancellation()
//        }
//        if quantityTypes.contains(.activeEnergy) {
//            try await setActiveEnergyFromHealthKit()
//            try Task.checkCancellation()
//        }
//        
//        await MainActor.run {
//            health.recalculate()
//        }
//    }
    

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
        
//        if leanBodyMassSource == .healthKit {
//            try await setLeanBodyMassFromHealthKit(preservingExistingValue: !isCurrent)
//            try Task.checkCancellation()
//        }
//        if sexSource == .healthKit {
//            try await setSexFromHealthKit(preservingExistingValue: !isCurrent)
//            try Task.checkCancellation()
//        }
//        if ageSource == .healthKit {
//            try await setAgeFromHealthKit(preservingExistingValue: !isCurrent)
//            try Task.checkCancellation()
//        }
//        if restingEnergySource == .healthKit {
//            try await setRestingEnergyFromHealthKit(preservingExistingValue: !isCurrent)
//            try Task.checkCancellation()
//        }
//        if activeEnergySource == .healthKit {
//            try await setActiveEnergyFromHealthKit(preservingExistingValue: !isCurrent)
//            try Task.checkCancellation()
//        }
        
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
        case .maintenanceEnergy, .fatPercentage, .pregnancyStatus, .isSmoker:
            false
        default:
            true
        }
    }
}

import HealthKit

public enum HealthKitValue {
    case weight(Quantity?)
    case height(Quantity?)
    case leanBodyMass(Quantity?)
    
    case restingEnergy(Double?)
    case activeEnergy(Double?)

    case sex(HKBiologicalSex?)
    case age(DateComponents?)
}

public extension HealthKitValue {
    var quantity: Quantity? {
        switch self {
        case .weight(let quantity):         quantity
        case .height(let quantity):         quantity
        case .leanBodyMass(let quantity):   quantity
        default: nil
        }
    }
    
    var sex: Sex? {
        switch self {
        case .sex(let biologicalSex): biologicalSex?.sex
        default: nil
        }
    }
    
    var dateComponents: DateComponents? {
        switch self {
        case .age(let dateComponents): dateComponents
        default: nil
        }
    }

    var double: Double? {
        switch self {
        case .activeEnergy(let double):     double
        case .restingEnergy(let double):    double
        default: nil
        }
    }

}

extension Health {
    
    func sourceIsHealthKit(for type: HealthType) -> Bool {
        switch type {
        case .weight:           weightSource == .healthKit
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
        case .weight:               weight?.quantity == nil
        case .height:               height?.quantity == nil
        case .age:                  age?.value == nil
        case .sex:                  sex?.value == nil
        case .leanBodyMass:         leanBodyMass?.quantity == nil
        case .activeEnergy:         activeEnergy?.value == nil
        case .restingEnergy:        restingEnergy?.value == nil
        case .maintenanceEnergy:    maintenanceEnergy == nil
        case .pregnancyStatus:      pregnancyStatus == nil
        case .isSmoker:             isSmoker == nil
        case .fatPercentage:        fatPercentage == nil
        }
    }
}
