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
            
                ignoreChanges = true
                
                health.weight = .init(source: .healthKit)
                health.height = .init(source: .healthKit)

//                weightSource = .healthKit
//                ageSource = .healthKit
//                heightSource = .healthKit
//                leanBodyMassSource = .healthKit
//                restingEnergySource = .healthKit
//                activeEnergySource = .healthKit
//                sexSource = .healthKit
            }
        }
        
        try await setFromHealthKit()

        await MainActor.run {
            withAnimation {
                ignoreChanges = false
            }
        }
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
        
        await hideProgressBar()
        
        /// If this isn't the current model (ie, a past one), don't clear out the value if its not available so that we preserve the validity of goals in plans as a priority
        if !isCurrent { guard value != nil else { return } }

        /// Checking for cancellation before setting the new value
        try Task.checkCancellation()

        /// Set the value with an animation
        await MainActor.run { [value] in
            withAnimation {
                setHealthKitValue(value, for: type)
            }
        }
    }
    
    func previewValue(for type: HealthType) async throws -> HealthKitValue? {
        try await sleepTask(1.0)
        return switch type {
        case .weight: .weight(.init(value: 83, date: Date.now.movingHourBy(-3)))
        case .height: .height(.init(value: 175, date: Date.now.moveDayBy(-1)))
        default: nil
        }
    }

    func setHealthKitValue(_ value: HealthKitValue?, for type: HealthType) {
        switch type {
        case .weight:
            health.weightQuantity = value?.quantity
        case .height:
            health.heightQuantity = value?.quantity
        default:
            break
        }
    }
    
    func healthKitValue(for type: HealthType) async throws -> HealthKitValue? {
        switch type {
        case .weight:
            .weight(try await HealthStore.weight(
                in: health.bodyMassUnit,
                for: health.date
            ))
        case .height:
            .height(try await HealthStore.height(
                in: health.heightUnit,
                for: health.date
            ))
        default:
            nil
        }
    }
    
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

    func setLeanBodyMassFromHealthKit(
        using unit: BodyMassUnit? = nil,
        preservingExistingValue: Bool = false
    ) async throws {
        
        let quantity = try await HealthStore.leanBodyMass(
            in: unit ?? health.bodyMassUnit,
            for: health.date
        )
        
        if preservingExistingValue { guard quantity != nil else { return } }

        try Task.checkCancellation()

        await MainActor.run {
            withAnimation {
                health.leanBodyMassQuantity = quantity
            }
        }
    }

    func setSexFromHealthKit(
        preservingExistingValue: Bool = false
    ) async throws {
        
        let healthKitSex = try await HealthStore.biologicalSex()
        
        if preservingExistingValue { guard healthKitSex != nil else { return } }

        try Task.checkCancellation()

        await MainActor.run {
            withAnimation {
                sexValue = healthKitSex?.sex
            }
        }
    }

    func setAgeFromHealthKit(
        preservingExistingValue: Bool = false
    ) async throws {
        
        let components = try await HealthStore.dateOfBirthComponents()
        
        print(String(describing: components))
        if preservingExistingValue { guard components != nil else { return } }

        try Task.checkCancellation()

        await MainActor.run {
            withAnimation {
                ageValue = components?.age ?? 0
            }
        }
    }

    func setRestingEnergyFromHealthKit(
        using energyUnit: EnergyUnit? = nil,
        preservingExistingValue: Bool = false
    ) async throws {
        
        guard let interval = health.restingEnergy?.interval else {
            return
        }

        await MainActor.run {
            withAnimation {
                startSettingTypeFromHealthKit(.restingEnergy)
            }
        }

        let value = try await HealthStore.restingEnergy(
            for: interval,
            on: health.date,
            in: energyUnit ?? health.energyUnit
        )
        
        try await sleepTask(3.0)
        
        try Task.checkCancellation()
        
        await MainActor.run {
            withAnimation {
                health.restingEnergy?.value = value
                stopSettingTypeFromHealthKit(.restingEnergy)
            }
        }
    }

    func setActiveEnergyFromHealthKit(
        using energyUnit: EnergyUnit? = nil,
        preservingExistingValue: Bool = false
    ) async throws {
        
        guard let interval = health.activeEnergy?.interval else {
            return
        }
        
        let value = try await HealthStore.activeEnergy(
            for: interval,
            on: health.date,
            in: energyUnit ?? health.energyUnit
        )

        try Task.checkCancellation()

        await MainActor.run {
            withAnimation {
                health.activeEnergy?.value = value
            }
        }
    }
}

public extension HealthModel {
    func shouldShowHealthKitError(for type: HealthType) -> Bool {
        health.isMissingHealthKitError(for: type)
        && !isSettingTypeFromHealthKit(type)
    }
}

public extension Health {
    func isMissingHealthKitError(for type: HealthType) -> Bool {
        switch type {
        case .weight:
            weightSource == .healthKit && weight?.quantity == nil
        case .height:
            heightSource == .healthKit && height?.quantity == nil
        default:
            false
        }
    }
}
