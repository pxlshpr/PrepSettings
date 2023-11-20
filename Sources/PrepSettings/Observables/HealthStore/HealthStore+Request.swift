import HealthKit
import PrepShared

let DefaultNumberOfDaysForAdaptiveMaintenance = 7
let DefaultNumberOfDaysForMovingAverage = 7

extension Health {
    
    func calculate() async throws -> Health.MaintenanceEnergy? {
        
        guard let maintenanceEnergy else { return nil }
        
        /// Fill in the `WeightChange` data by fetching from HealthKit or backend
        let weightChange = try await fillWeightChange(maintenanceEnergy.weightChange)
        
        /// Fill in the `DietaryEnergy` data by fetching from HealthKit or backend
        let dietaryEnergy = try await fillDietaryEnergy(maintenanceEnergy.dietaryEnergy)
        
        /// Now create the Maintenance energy with the filled in `WeightChange` and `DietaryEnergy` which attempts to calculate it and sets a value or an error accordingly
        return Health.MaintenanceEnergy(
            interval: maintenanceEnergy.interval,
            weightChange: weightChange,
            dietaryEnergy: dietaryEnergy
        )
    }
    
    public func fillWeightChange(_ weightChange: WeightChange) async throws -> WeightChange {
        
        let interval = maintenanceEnergy?.interval ?? .init(1, .week)
        
        var weightChange = weightChange
        
        func request(for date: Date) -> HealthKitQuantityRequest {
            HealthKitQuantityRequest(.weight, bodyMassUnit.healthKitUnit, date)
        }
        
        switch weightChange.current.type {
        case .healthKit:
            try await weightChange.current.fill(using: request(for: date))
        default:
            break
        }
        
        switch weightChange.previous.type {
        case .healthKit:
            let previousDate = interval.startDate(with: date)
            try await weightChange.previous.fill(using: request(for: previousDate))
        default:
            break
        }
        
        return weightChange
    }
    
    public func fillDietaryEnergy(_ dietaryEnergy: DietaryEnergy) async throws -> DietaryEnergy {
        
        var dietaryEnergy = dietaryEnergy
        
        /// If we have any `HealthKit` sourced dietary energy values in the samples, this will be indicated by a range of dates provided
        if let dateRange = dietaryEnergy.healthKitDatesRange(for: date) {
            /// If we do, grab the values that coincide with these dates
            let values = try await HealthStore.dailyDietaryEnergyValues(
                dateRange: dateRange,
                energyUnit: energyUnit
            )
            for i in values.keys {
                guard i < dietaryEnergy.samples.count else { continue }
                dietaryEnergy.samples[i].value = values[i]
            }
        }
        
        /// Now grab any backend sourced dietary energy values

        /// Once this is done, fill in the empty values with the averages
        dietaryEnergy.fillEmptyValuesWithAverages()

        return dietaryEnergy
//        return try await HealthKitEnergyRequest(
//            .dietary,
//            energyUnit,
//            .init(dietaryEnergy.samples.count, .day),
//            date
//        )
//        .dietaryEnergy()
    }
}

extension HealthStore {
    
//    public static func mockAdaptiveMaintenanceEnergy(
//        weightMovingAverageDays: Int? = nil
//    ) async throws -> Health.MaintenanceEnergy? {
//        let weightChange = try await adaptiveWeightData(
//            in: bodyMassUnit,
//            on: date,
//            interval: interval,
//            asMovingAverageOfNumberOfDays: weightMovingAverageDays
//        )
//        
//        let dietaryEnergy = try await adaptiveDietaryEnergyData(
//            interval: interval,
//            date: date,
//            unit: energyUnit
//        )
//        
//        return Health.MaintenanceEnergy(
//            interval: interval,
//            weightChange: weightChange,
//            dietaryEnergy: dietaryEnergy
//        )
//    }

//    public static func fillWeightChange(
//        _ weightChange: WeightChange,
//        in unit: BodyMassUnit = .kg,
//        on date: Date = Date.now,
//        interval: HealthInterval
//    ) async throws -> WeightChange {
//        var weightChange = weightChange
//        
//        func request(for date: Date) -> HealthKitQuantityRequest {
//            HealthKitQuantityRequest(.weight, unit.healthKitUnit, date)
//        }
//        
//        if weightChange.current.type == .healthKit {
//            try await weightChange.current.fill(using: request(for: date))
//        }
//        if weightChange.previous.type == .healthKit {
//            let previousDate = interval.startDate(with: date)
//            try await weightChange.previous.fill(using: request(for: previousDate))
//        }
//        return weightChange
////        try await HealthKitQuantityRequest(.weight, unit.healthKitUnit, date)
////            .weightChange(interval: interval, weightChange: weightChange)
//    }

    
//    public static func fillDietaryEnergy(
//        _ dietaryEnergy: DietaryEnergy,
//        date: Date = Date.now,
//        unit: EnergyUnit = .kcal
//    ) async throws -> DietaryEnergy {
//        try await HealthKitEnergyRequest(
//            .dietary,
//            unit, 
//            .init(dietaryEnergy.samples.count, .day),
//            date
//        )
//        .dietaryEnergy()
//    }
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

