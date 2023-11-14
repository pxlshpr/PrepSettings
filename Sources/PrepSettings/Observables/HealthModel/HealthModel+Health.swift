import SwiftUI
import PrepShared
import SwiftSugar

var isPreview: Bool {
    return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
}

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
        
        case .maintenanceEnergy:       .maintenanceEnergy(nil, .noWeightData)

        default: nil
        }
    }

    func healthKitValue(for type: HealthType) async throws -> HealthKitValue? {
        switch type {
        case .weight: return .weight(
            try await HealthStore.weight(in: health.bodyMassUnit, for: health.date)
        )
        case .height: return .height(
            try await HealthStore.height(in: health.heightUnit, for: health.date)
        )
        case .leanBodyMass: return .leanBodyMass(
            try await HealthStore.leanBodyMass(in: health.bodyMassUnit, for: health.date)
        )
        case .sex: return .sex(
            try await HealthStore.biologicalSex()
        )
        case .age: return .age(
            try await HealthStore.dateOfBirthComponents()
        )
        case .maintenanceEnergy:
            //TODO: Do this
            return .maintenanceEnergy(nil, .noWeightData)
//            return .maintenanceEnergy(2693)

        case .restingEnergy:
            guard let interval = health.restingEnergy?.interval else {
                return nil
            }
            return .restingEnergy(
                try await HealthStore.restingEnergy(
                    for: interval,
                    on: health.date,
                    in: health.energyUnit
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
                    in: health.energyUnit
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

public extension Health {
    func isMissingHealthKitValue(for type: HealthType) -> Bool {
        sourceIsHealthKit(for: type) && valueIsNil(for: type)
    }
    
    mutating func initializeHealthKitValues() {
        weight = .init(source: .healthKit)
        height = .init(source: .healthKit)
        sex = .init(source: .healthKit)
        age = .init(source: .healthKit)
        leanBodyMass = .init(source: .healthKit)
        restingEnergy = .init(source: .healthKit)
        activeEnergy = .init(source: .healthKit)
    }
    
    mutating func setHealthKitValue(_ value: HealthKitValue?, for type: HealthType) {
        
        switch type {
        case .weight:           weightQuantity = value?.quantity
        case .height:           heightQuantity = value?.quantity
        case .leanBodyMass:     leanBodyMassQuantity = value?.quantity
            
        case .restingEnergy:    restingEnergyValue = value?.double
        case .activeEnergy:     activeEnergyValue = value?.double
            
        case .sex:              sexValue = value?.sex
        case .age:              ageHealthKitDateComponents = value?.dateComponents

        case .maintenanceEnergy:
            maintenanceEnergyCalculatedValue = value?.double
            maintenanceEnergyCalculationError = value?.maintenanceCalculationError

        default:                break
        }
    }
    
}


//MARK: - Legacy

extension HealthModel {
//    func setWeightFromHealthKit(
//        using unit: BodyMassUnit? = nil
//    ) async throws {
//
//        await MainActor.run {
//            withAnimation {
//                startSettingTypeFromHealthKit(.weight)
//            }
//        }
//
//        var quantity: Quantity? = nil
//        if isPreview {
//            try await sleepTask(1.0)
//            quantity = .init(value: 83, date: Date.now.movingHourBy(-3))
////            quantity = nil
//        } else {
//            quantity = try await HealthStore.weight(
//                in: unit ?? health.bodyMassUnit,
//                for: health.date
//            )
//        }
//
//        await MainActor.run {
//            withAnimation {
//                stopSettingTypeFromHealthKit(.weight)
//            }
//        }
//
//        /// If this isn't the current model (ie, a past one), don't clear out the value if its not available so that we preserve the validity of goals in plans as a priority
//        if !isCurrent { guard quantity != nil else { return } }
//
//        try Task.checkCancellation()
//
//        await MainActor.run { [quantity] in
//            withAnimation {
//                health.weightQuantity = quantity
//            }
//        }
//    }
//
//    func setHeightFromHealthKit(
//        using unit: HeightUnit? = nil
//    ) async throws {
//
//        await MainActor.run {
//            withAnimation {
//                startSettingTypeFromHealthKit(.height)
//            }
//        }
//
//        var quantity: Quantity? = nil
//        if isPreview {
//            try await sleepTask(1.0)
//            quantity = .init(value: 175, date: Date.now.moveDayBy(-1))
//        } else {
//            quantity = try await HealthStore.height(
//                in: unit ?? health.heightUnit,
//                for: health.date
//            )
//        }
//
//        await MainActor.run {
//            withAnimation {
//                stopSettingTypeFromHealthKit(.height)
//            }
//        }
//
//        if !isCurrent { guard quantity != nil else { return } }
//
//        try Task.checkCancellation()
//
//        await MainActor.run { [quantity] in
//            withAnimation {
//                health.heightQuantity = quantity
//            }
//        }
//    }
//
//    func setLeanBodyMassFromHealthKit(
//        using unit: BodyMassUnit? = nil,
//        preservingExistingValue: Bool = false
//    ) async throws {
//        
//        let quantity = try await HealthStore.leanBodyMass(
//            in: unit ?? health.bodyMassUnit,
//            for: health.date
//        )
//        
//        if preservingExistingValue { guard quantity != nil else { return } }
//
//        try Task.checkCancellation()
//
//        await MainActor.run {
//            withAnimation {
//                health.leanBodyMassQuantity = quantity
//            }
//        }
//    }
//
//    func setSexFromHealthKit(
//        preservingExistingValue: Bool = false
//    ) async throws {
//        
//        let healthKitSex = try await HealthStore.biologicalSex()
//        
//        if preservingExistingValue { guard healthKitSex != nil else { return } }
//
//        try Task.checkCancellation()
//
//        await MainActor.run {
//            withAnimation {
//                sexValue = healthKitSex?.sex
//            }
//        }
//    }
//    
//    func setAgeFromHealthKit(
//        preservingExistingValue: Bool = false
//    ) async throws {
//        
//        let components = try await HealthStore.dateOfBirthComponents()
//        
//        if preservingExistingValue { guard components != nil else { return } }
//
//        try Task.checkCancellation()
//
//        await MainActor.run {
//            withAnimation {
//                ageValue = components?.age ?? 0
//            }
//        }
//    }
//    
//    func setRestingEnergyFromHealthKit(
//        using energyUnit: EnergyUnit? = nil,
//        preservingExistingValue: Bool = false
//    ) async throws {
//        
//        guard let interval = health.restingEnergy?.interval else {
//            return
//        }
//
//        await MainActor.run {
//            withAnimation {
//                startSettingTypeFromHealthKit(.restingEnergy)
//            }
//        }
//
//        let value = try await HealthStore.restingEnergy(
//            for: interval,
//            on: health.date,
//            in: energyUnit ?? health.energyUnit
//        )
//        
//        try await sleepTask(3.0)
//        
//        try Task.checkCancellation()
//        
//        await MainActor.run {
//            withAnimation {
//                health.restingEnergy?.value = value
//                stopSettingTypeFromHealthKit(.restingEnergy)
//            }
//        }
//    }
//
//    func setActiveEnergyFromHealthKit(
//        using energyUnit: EnergyUnit? = nil,
//        preservingExistingValue: Bool = false
//    ) async throws {
//        
//        guard let interval = health.activeEnergy?.interval else {
//            return
//        }
//        
//        let value = try await HealthStore.activeEnergy(
//            for: interval,
//            on: health.date,
//            in: energyUnit ?? health.energyUnit
//        )
//
//        try Task.checkCancellation()
//
//        await MainActor.run {
//            withAnimation {
//                health.activeEnergy?.value = value
//            }
//        }
//    }
}
