import SwiftUI
import PrepShared

public extension BiometricsStore {
    func setAllFromHealth() async throws {
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
        weightSource = .health
        ageSource = .health
        heightSource = .health
        leanBodyMassSource = .health
        restingEnergySource = .health
        activeEnergySource = .health
        sexSource = .health
    }
}
public extension BiometricsStore {

    func setWeightFromHealth(
        using unit: BodyMassUnit? = nil,
        preservingExistingValue: Bool = false
    ) async throws {
        
        let quantity = try await HealthStore.weight(
            in: unit ?? biometrics.bodyMassUnit,
            for: biometrics.date
        )
        
        if preservingExistingValue { guard quantity != nil else { return } }
        
        try Task.checkCancellation()

        await MainActor.run {
            withAnimation {
                biometrics.weightQuantity = quantity
            }
        }
    }

    func setHeightFromHealth(
        using unit: HeightUnit? = nil,
        preservingExistingValue: Bool = false
    ) async throws {
        
        let quantity = try await HealthStore.height(
            in: unit ?? biometrics.heightUnit,
            for: biometrics.date
        )
        
        if preservingExistingValue { guard quantity != nil else { return } }

        try Task.checkCancellation()

        await MainActor.run {
            withAnimation {
                biometrics.heightQuantity = quantity
            }
        }
    }

    func setLeanBodyMassFromHealth(
        using unit: BodyMassUnit? = nil,
        preservingExistingValue: Bool = false
    ) async throws {
        
        let quantity = try await HealthStore.leanBodyMass(
            in: unit ?? biometrics.bodyMassUnit,
            for: biometrics.date
        )
        
        if preservingExistingValue { guard quantity != nil else { return } }

        try Task.checkCancellation()

        await MainActor.run {
            withAnimation {
                biometrics.leanBodyMassQuantity = quantity
            }
        }
    }

    func setSexFromHealth(
        preservingExistingValue: Bool = false
    ) async throws {
        
        let sex = try await HealthStore.biologicalSex()
        
        if preservingExistingValue { guard sex != nil else { return } }

        try Task.checkCancellation()

        await MainActor.run {
            withAnimation {
                sexValue = sex?.biometricSex
            }
        }
    }

    func setAgeFromHealth(
        preservingExistingValue: Bool = false
    ) async throws {
        
        let components = try await HealthStore.dateOfBirthComponents()
        
        if preservingExistingValue { guard components != nil else { return } }

        try Task.checkCancellation()

        await MainActor.run {
            withAnimation {
                ageValue = components?.age ?? 0
            }
        }
    }

    func setRestingEnergyFromHealth(
        using energyUnit: EnergyUnit? = nil,
        preservingExistingValue: Bool = false
    ) async throws {
        
        guard let interval = biometrics.restingEnergy?.interval else {
            return
        }

        let value = try await HealthStore.restingEnergy(
            for: interval,
            on: biometrics.date,
            in: energyUnit ?? biometrics.energyUnit
        )
        
        try Task.checkCancellation()
        
        await MainActor.run {
            withAnimation {
                biometrics.restingEnergy?.value = value
            }
        }
    }

    func setActiveEnergyFromHealth(
        using energyUnit: EnergyUnit? = nil,
        preservingExistingValue: Bool = false
    ) async throws {
        
        guard let interval = biometrics.activeEnergy?.interval else {
            return
        }
        
        let value = try await HealthStore.activeEnergy(
            for: interval,
            on: biometrics.date,
            in: energyUnit ?? biometrics.energyUnit
        )

        try Task.checkCancellation()

        await MainActor.run {
            withAnimation {
                biometrics.activeEnergy?.value = value
            }
        }
    }
}
