import SwiftUI
import PrepShared
import SwiftSugar

public extension HealthModel {
    func setAllFromHealthKit() async throws {
        if !isPreview {
            try await HealthStore.requestPermissions(
                characteristicTypeIdentifiers: [
                    .biologicalSex,
                    .dateOfBirth
                ],
                quantityTypeIdentifiers: [
                    .activeEnergyBurned,
                    .basalEnergyBurned,
                    .bodyMass,
                    .leanBodyMass,
                    .height
                ]
            )
        }
        

        /// Now that we have permissions, set the sources to `health`, which should also set the values themselves

        await MainActor.run {
            withAnimation {
                typesBeingSetFromHealthKit = [
                    .weight, .age, .height, .leanBodyMass, .restingEnergy, .activeEnergy, .sex
                ]
            
                /// Set this until after we've set values from health kit so that we don't keep handling each successive change
                ignoreChanges = true
                
                health.initializeHealthKitValues()
            }
        }
        
        try await setFromHealthKit()
        try await saveHealth()
        ignoreChanges = false
    }
}

public extension HealthModel {

    func setTypeFromHealthKit(_ type: HealthType) async throws {
        
        func showProgressBar() async {
            await MainActor.run { withAnimation { startSettingTypeFromHealthKit(type) } }
        }
        
        func hideProgressBar() async {
            await MainActor.run { withAnimation { stopSettingTypeFromHealthKit(type) } }
        }

        await showProgressBar()
        
        /// Get the value here
        let value = if isPreview {
            try await previewValue(for: type)
        } else {
            try await healthKitValue(for: type)
        }
        
        /// If this isn't the current model (ie, a past one), don't clear out the value if its not available so that we preserve the validity of goals in plans as a priority
        if !isCurrent { guard value != nil else { return } }

        /// Checking for cancellation before setting the new value
        try Task.checkCancellation()

        /// Set the value with an animation
        await MainActor.run { [value] in
            withAnimation {
                health.setHealthKitValue(value, for: type)
            }
        }
        
        await hideProgressBar()
    }
    
    func previewValue(for type: HealthType) async throws -> HealthKitValue? {
        try await sleepTask(1.0)
        return switch type {
        case .weight:           .weight(.init(value: 83, date: Date.now.movingHourBy(-3)))
        case .height:           .height(.init(value: 175, date: Date.now.moveDayBy(-1)))
        case .leanBodyMass:     .leanBodyMass(.init(value: 67, date: Date.now.movingHourBy(-3)))
        case .restingEnergy:    .restingEnergy(1600)
        case .activeEnergy:     .activeEnergy(400)
        case .sex:              .sex(.male)
        case .age:              .age(DefaultDateOfBirth.dateComponentsWithoutTime)
        
        case .maintenanceEnergy:
                .maintenanceEnergy(Health.MaintenanceEnergy(isAdaptive: true))
//            if [1, 2].randomElement() == 1 {
//                .maintenanceEnergy(Health.MaintenanceEnergy(adaptiveValue: 0, error: .noWeightData))
//            } else {
//                .maintenanceEnergy(Health.MaintenanceEnergy(adaptiveValue: 2693, error: nil))
//            }

        default: nil
        }
    }

    func healthKitValue(for type: HealthType) async throws -> HealthKitValue? {
        switch type {
        case .weight: return .weight(
            try await HealthStore.weight(in: .kg, for: health.date)
//            try await HealthStore.weight(in: health.bodyMassUnit, for: health.date)
        )
        case .height: return .height(
            try await HealthStore.height(in: .cm, for: health.date)
//            try await HealthStore.height(in: health.heightUnit, for: health.date)
        )
        case .leanBodyMass: return .leanBodyMass(
            try await HealthStore.leanBodyMass(in: .kg, for: health.date)
//            try await HealthStore.leanBodyMass(in: health.bodyMassUnit, for: health.date)
        )
        case .sex: return .sex(
            try await HealthStore.biologicalSex()
        )
        case .age: return .age(
            try await HealthStore.dateOfBirthComponents()
        )
        case .maintenanceEnergy:
            guard let maintenance = try await health.calculate() else {
                return nil
            }
            return .maintenanceEnergy(maintenance)

        case .restingEnergy:
            guard let interval = health.restingEnergy?.interval else {
                return nil
            }
            return .restingEnergy(
                try await HealthStore.restingEnergy(
                    for: interval,
                    on: health.date,
                    in: .kcal
//                    in: health.energyUnit
            )
        )
        case .activeEnergy:
            guard let interval = health.activeEnergy?.interval else {
                return nil
            }
            
            return .activeEnergy(
                try await HealthStore.activeEnergy(
                    for: interval,
                    on: health.date,
                    in: .kcal
//                    in: health.energyUnit
            )
        )

        default:
            return nil
        }
    }
}

public extension HealthModel {
    func shouldShowHealthKitError(for type: HealthType) -> Bool {
        health.isMissingHealthKitValue(for: type)
        && !isSettingTypeFromHealthKit(type)
    }
}

public extension HealthModel {
    func isSettingTypeFromHealthKit(_ type: HealthType) -> Bool {
        typesBeingSetFromHealthKit.contains(type)
    }
    
    func startSettingTypeFromHealthKit(_ type: HealthType) {
        guard !isSettingTypeFromHealthKit(type) else { return }
        typesBeingSetFromHealthKit.append(type)
    }
    
    func stopSettingTypeFromHealthKit(_ type: HealthType) {
        guard isSettingTypeFromHealthKit(type) else { return }
        typesBeingSetFromHealthKit.removeAll(where: { $0 == type })
    }
    
    var isSettingMaintenanceFromHealthKit: Bool {
        if health.maintenanceEnergyIsAdaptive, isSettingTypeFromHealthKit(.maintenanceEnergy) {
            return true
        } else if !(health.maintenanceEnergyIsAdaptive && health.maintenanceEnergy?.adaptiveValue != nil) {
            return isSettingTypeFromHealthKit(.restingEnergy) || isSettingTypeFromHealthKit(.activeEnergy)
        }
        return false
    }
}
