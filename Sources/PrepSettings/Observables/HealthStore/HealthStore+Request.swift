import HealthKit
import PrepShared

let DefaultNumberOfDaysForAdaptiveMaintenance = 7
let DefaultNumberOfDaysForMovingAverage = 7

extension HealthStore {
    
    public static func adaptiveMaintenanceEnergy(
        energyUnit: EnergyUnit = .kcal,
        bodyMassUnit: BodyMassUnit = .kg,
        on date: Date = Date.now,
        interval: HealthInterval = .init(1, .week),
        weightMovingAverageDays: Int? = nil
    ) async throws -> Health.MaintenanceEnergy? {
        let weightChange = try await adaptiveWeightData(
            in: bodyMassUnit,
            on: date,
            interval: interval,
            asMovingAverageOfNumberOfDays: weightMovingAverageDays
        )
        
        let dietaryEnergy = try await adaptiveDietaryEnergyData(
            interval: interval,
            date: date,
            unit: energyUnit
        )
        
        return Health.MaintenanceEnergy(
            isAdaptive: true,
            adaptiveValue: nil,
            error: nil,
            interval: interval,
            weightChange: weightChange,
            dietaryEnergy: dietaryEnergy
        )
    }
    
    //TODO: Modify asMovingAverageOfNumberOfDays with HealthInterval
    public static func adaptiveWeightData(
        in unit: BodyMassUnit = .kg,
        on date: Date = Date.now,
        interval: HealthInterval,
        asMovingAverageOfNumberOfDays movingAverageDays: Int? = nil
    ) async throws -> WeightChange {
        try await HealthKitQuantityRequest(.weight, unit.healthKitUnit, date)
            .weightChange(
                interval: interval,
                asMovingAverageOfNumberOfDays: movingAverageDays
            )
    }
    
    public static func adaptiveDietaryEnergyData(
        interval: HealthInterval = .init(0, .day),
        date: Date = Date.now,
        unit: EnergyUnit = .kcal
    ) async throws -> DietaryEnergy {
        try await HealthKitEnergyRequest(.dietary, unit, interval, date)
            .dietaryEnergy()
    }
}

extension HealthStore {
    
    static func weight(
        in unit: BodyMassUnit = .kg,
        for date: Date = Date.now
    ) async throws -> Quantity? {
        try await HealthKitQuantityRequest(.weight, unit.healthKitUnit, date)
            .mostRecentOrEarliestAvailable()
    }

    static func leanBodyMass(
        in unit: BodyMassUnit = .kg,
        for date: Date = Date.now
    ) async throws -> Quantity? {
        try await HealthKitQuantityRequest(.leanBodyMass, unit.healthKitUnit, date)
            .mostRecentOrEarliestAvailable()
    }

    static func height(
        in unit: HeightUnit = .cm,
        for date: Date = Date.now
    ) async throws -> Quantity? {
        try await HealthKitQuantityRequest(.height, unit.healthKitUnit, date)
            .mostRecentOrEarliestAvailable()
    }

    static func biologicalSex() async throws -> HKBiologicalSex? {
        try await requestPermission(for: .biologicalSex)
        return try store.biologicalSex().biologicalSex
    }
    
    static func dateOfBirthComponents() async throws -> DateComponents? {
        try await requestPermission(for: .dateOfBirth)
        return try store.dateOfBirthComponents()
    }

    static func restingEnergy(
        for interval: HealthInterval = .init(0, .day),
        on date: Date = Date.now,
        in unit: EnergyUnit = .kcal
    ) async throws -> Double {
        try await HealthKitEnergyRequest(.resting, unit, interval, date).dailyAverage()
    }
    
    static func activeEnergy(
        for interval: HealthInterval = .init(0, .day),
        on date: Date = Date.now,
        in unit: EnergyUnit = .kcal
    ) async throws -> Double {
        try await HealthKitEnergyRequest(.active, unit, interval, date).dailyAverage()
    }
}

