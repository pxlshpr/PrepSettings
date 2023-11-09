import SwiftUI
import PrepShared

public extension HealthModel {
    func setAllFromHealthKit() async throws {
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
        
        /// Now that we have permissions, set the sources to `health`, which should also set the values themselves
        weightSource = .healthKit
        ageSource = .healthKit
        heightSource = .healthKit
        leanBodyMassSource = .healthKit
        restingEnergySource = .healthKit
        activeEnergySource = .healthKit
        sexSource = .healthKit
    }
}
public extension HealthModel {

    func setWeightFromHealthKit(
        using unit: BodyMassUnit? = nil,
        preservingExistingValue: Bool = false
    ) async throws {
        
        let quantity = try await HealthStore.weight(
            in: unit ?? health.bodyMassUnit,
            for: health.date
        )
        
        if preservingExistingValue { guard quantity != nil else { return } }
        
        try Task.checkCancellation()

        await MainActor.run {
            withAnimation {
                health.weightQuantity = quantity
            }
        }
    }

    func setHeightFromHealthKit(
        using unit: HeightUnit? = nil,
        preservingExistingValue: Bool = false
    ) async throws {
        
        let quantity = try await HealthStore.height(
            in: unit ?? health.heightUnit,
            for: health.date
        )
        
        if preservingExistingValue { guard quantity != nil else { return } }

        try Task.checkCancellation()

        await MainActor.run {
            withAnimation {
                health.heightQuantity = quantity
            }
        }
    }

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

        let value = try await HealthStore.restingEnergy(
            for: interval,
            on: health.date,
            in: energyUnit ?? health.energyUnit
        )
        
        try Task.checkCancellation()
        
        await MainActor.run {
            withAnimation {
                health.restingEnergy?.value = value
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
