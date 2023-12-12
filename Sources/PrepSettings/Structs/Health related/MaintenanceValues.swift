import Foundation

public struct WeightValues: Codable {
    public var values: [Date: HealthQuantity] = [:]
}

public struct DietaryEnergyValues: Codable {
    public var values: [Date: Value] = [:]

    public struct Value: Codable {
        public var dietaryEnergyInKcal: Double?
        public var dietaryEnergyType: DietaryEnergySampleType
    }
}

public struct MaintenanceValues: Codable {
    
    public var values: [Date : Value]
    
    public struct Value: Codable {
        public var weightInKg: Double?
        public var dietaryEnergyInKcal: Double?
        public var dietaryEnergyType: DietaryEnergySampleType
        
        public init(
            weightInKg: Double? = nil,
            dietaryEnergyInKcal: Double? = nil,
            dietaryEnergyType: DietaryEnergySampleType
        ) {
            self.weightInKg = weightInKg
            self.dietaryEnergyInKcal = dietaryEnergyInKcal
            self.dietaryEnergyType = dietaryEnergyType
        }
    }
    
    public init(
        dateRange: ClosedRange<Date>,
        weightValues: WeightValues,
        dietaryEnergyValues: DietaryEnergyValues
    ) {
        let dayDurationInSeconds: TimeInterval = 60*60*24
        var values: [Date : Value] = [:]
        for date in stride(
            from: dateRange.lowerBound,
            to: dateRange.upperBound,
            by: dayDurationInSeconds
        ) {
            let weightInKg = weightValues.values[date]?.quantity?.value
            let dietaryEnergyValue = dietaryEnergyValues.values[date]
            values[date] = .init(
                weightInKg: weightInKg,
                dietaryEnergyInKcal: dietaryEnergyValue?.dietaryEnergyInKcal,
                dietaryEnergyType: dietaryEnergyValue?.dietaryEnergyType ?? .userEntered
            )
        }
        self.values = values
    }
    
    public init(values: [Date : Value]) {
        self.values = values
    }
    
    public init(_ dict: [Date: (Double?, Double?)]) {
        var values: [Date: Value] = [:]
        for (date, (weight, energy)) in dict {
            let value = Value(
                weightInKg: weight,
                dietaryEnergyInKcal: energy,
                dietaryEnergyType: .logged
            )
            values[date] = value
        }
        self.values = values
    }
}

public extension MaintenanceValues {
    mutating func setWeightInKg(_ value: Double, for date: Date) {
        values[date]?.weightInKg = value
    }
    
    mutating func setDietaryEnergyInKcal(_ value: Double, for date: Date, type: DietaryEnergySampleType) {
        values[date]?.dietaryEnergyInKcal = value
        values[date]?.dietaryEnergyType = type
    }
    
    func weightInKg(on date: Date) -> Double? {
        values[date]?.weightInKg
    }
    
    func dietaryEnergyInKcal(for date: Date) -> Double? {
        values[date]?.dietaryEnergyInKcal
    }
    
    func dietaryEnergyType(for date: Date) -> DietaryEnergySampleType? {
        values[date]?.dietaryEnergyType
    }
}

extension MaintenanceValues {
    
    var sortedDates: [Date] {
        values.keys.sorted()
    }
    
    var datesWithoutWeights: [Date]? {
        var dates: [Date] = []
        for date in sortedDates {
            guard values[date]?.weightInKg == nil else { continue }
            dates.append(date)
        }
        return dates.isEmpty ? nil : dates
    }
    
    var datesWithoutDietaryEnergy: [Date]? {
        var dates: [Date] = []
        for date in sortedDates {
            guard values[date]?.dietaryEnergyInKcal == nil else { continue }
            dates.append(date)
        }
        return dates.isEmpty ? nil : dates
    }
}

extension MaintenanceValues {
//    mutating func fillInMissingWeightsFromHealthKit(healthModel: HealthModel) async throws {
//
//        /// Get the range of days that are missing weight data and query them from HealthKit
//        guard let datesWithoutWeights else { return }
//
//        let healthKitValues = try await HealthKitQuantityRequest.weight
//            .quantities(for: datesWithoutWeights)
//            .valuesGroupedByDate
//        
//        for (date, quantities) in healthKitValues {
//            guard
//                let averageValue = quantities.averageValue,
//                let lastQuantity = quantities.sortedByDate.last
//            else { continue }
//            
//            /// Set the fetched value
//            setWeightInKg(averageValue, for: date)
//            
//            //TODO: Consider sending this to another parallel task so we don't have to wait for it (first test how long this takes in practice)
//            try await healthModel.delegate.updateBackendWeight(
//                for: date,
//                with: lastQuantity,
//                source: .healthKit
//            )
//        }
//    }
    
    mutating func fillInMissingDietaryEnergyFromHealthKit() async throws {
        
        guard let dates = datesWithoutDietaryEnergy else { return }
        
        let healthKitValues = try await HealthStore
            .dailyDietaryEnergyTotalsInKcal(for: dates)
        
        for (date, value) in  healthKitValues {
            setDietaryEnergyInKcal(value, for: date, type: .healthKit)
        }
    }
}
