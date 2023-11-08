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
    
    func handleChanges(from old: Health) async throws {
        
        /// Request for permissions
        let quantityTypes = health.quantityTypesToSync(from: old)
        let characteristicTypeIdentifiers = health.characteristicTypesToSync(from: old)
        if !quantityTypes.isEmpty || !characteristicTypeIdentifiers.isEmpty {
            try await HealthStore.requestPermissions(
                characteristicTypeIdentifiers: characteristicTypeIdentifiers,
                quantityTypes: quantityTypes
            )
            try Task.checkCancellation()
        }
        
        /// Trigger HealthKit syncs for any that were turned on
        if quantityTypes.contains(.weight) {
            try await setWeightFromHealthKit()
            try Task.checkCancellation()
        }
        if quantityTypes.contains(.leanBodyMass) {
            try await setLeanBodyMassFromHealthKit()
            try Task.checkCancellation()
        }
        if quantityTypes.contains(.height) {
            try await setHeightFromHealthKit()
            try Task.checkCancellation()
        }
        if characteristicTypeIdentifiers.contains(.sex) {
            try await setSexFromHealthKit()
            try Task.checkCancellation()
        }
        if characteristicTypeIdentifiers.contains(.dateOfBirth) {
            try await setAgeFromHealthKit()
            try Task.checkCancellation()
        }
        if quantityTypes.contains(.restingEnergy) {
            try await setRestingEnergyFromHealthKit()
            try Task.checkCancellation()
        }
        if quantityTypes.contains(.activeEnergy) {
            try await setActiveEnergyFromHealthKit()
            try Task.checkCancellation()
        }
        
        await MainActor.run {
            health.recalculate()
        }
    }
    
    func setFromHealthKit() async throws {
        if weightSource == .healthKit {
            try await setWeightFromHealthKit(preservingExistingValue: !isCurrent)
            try Task.checkCancellation()
        }
        if leanBodyMassSource == .healthKit {
            try await setLeanBodyMassFromHealthKit(preservingExistingValue: !isCurrent)
            try Task.checkCancellation()
        }
        if heightSource == .healthKit {
            try await setHeightFromHealthKit(preservingExistingValue: !isCurrent)
            try Task.checkCancellation()
        }
        if sexSource == .healthKit {
            try await setSexFromHealthKit(preservingExistingValue: !isCurrent)
            try Task.checkCancellation()
        }
        if ageSource == .healthKit {
            try await setAgeFromHealthKit(preservingExistingValue: !isCurrent)
            try Task.checkCancellation()
        }
        if restingEnergySource == .healthKit {
            try await setRestingEnergyFromHealthKit(preservingExistingValue: !isCurrent)
            try Task.checkCancellation()
        }
        if activeEnergySource == .healthKit {
            try await setActiveEnergyFromHealthKit(preservingExistingValue: !isCurrent)
            try Task.checkCancellation()
        }
        
        await MainActor.run {
            health.recalculate()
        }
    }
}
