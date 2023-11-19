import HealthKit
import PrepShared

struct HealthKitEnergyRequest {
    let energyType: EnergyType
    let energyUnit: EnergyUnit
    let interval: HealthInterval
    let date: Date
    
    init(
        _ energyType: EnergyType,
        _ energyUnit: EnergyUnit,
        _ interval: HealthInterval,
        _ date: Date
    ) {
        self.energyType = energyType
        self.energyUnit = energyUnit
        self.interval = interval
        self.date = date
    }
}

extension HealthKitEnergyRequest {
    var intervalType: HealthIntervalType { interval.intervalType }
    var typeIdentifier: HKQuantityTypeIdentifier { energyType.healthKitTypeIdentifier }
    var quantityType: HKQuantityType { HKQuantityType(typeIdentifier)}
    var unit: HKUnit { energyUnit.healthKitUnit }
    
    func requestPersmissions() async throws {
        try await HealthStore.requestPermissions(quantityTypeIdentifiers: [typeIdentifier])
    }
    
    var startDate: Date { interval.startDate(with: date) }
    var dateRange: ClosedRange<Date> { interval.dateRange(with: date) }
}

extension HealthKitEnergyRequest {
    
    func dailyStatistics(from startDate: Date, to endDate: Date) async throws -> HKStatisticsCollection {
        try await requestPersmissions()

        /// Always get samples up to the start of the next day, so that we get all of `date`'s results too
        let endDate = endDate.startOfDay.moveDayBy(1)
        
        let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)

        /// Create the query descriptor.
        let type = HKSampleType.quantityType(forIdentifier: typeIdentifier)!
        let samplesPredicate = HKSamplePredicate.quantitySample(type: type, predicate: datePredicate)

        /// We want the sum of each day
        let everyDay = DateComponents(day: 1)

        let asyncQuery = HKStatisticsCollectionQueryDescriptor(
            predicate: samplesPredicate,
            options: .cumulativeSum,
            anchorDate: endDate,
            intervalComponents: everyDay
        )
        return try await asyncQuery.result(for: HealthStore.store)
    }
    
    func dailyAverage() async throws -> Double {
        
        let statisticsCollection = try await dailyStatistics(from: startDate, to: date)
        
        var sumQuantities: [Date: HKQuantity] = [:]
        for day in dateRange.days {
            guard let statistics = statisticsCollection.statistics(for: day) else {
                throw HealthStoreError.couldNotGetStatistics
            }
            guard let sumQuantity = statistics.sumQuantity() else {
                continue
            }
            sumQuantities[day] = sumQuantity
        }
        
        guard !sumQuantities.isEmpty else {
            return 0
        }
        
        let sum = sumQuantities
            .values
            .map { $0.doubleValue(for: unit) }
            .reduce(0, +)
        
        /// Average by the number of `sumQuantities`, to filter out days that may not have been logged (by not wearing the Apple Watch, for instance)—which would otherwise skew the results to be lower.
        return sum / Double(sumQuantities.count)
    }
}

extension HealthKitEnergyRequest {
    
    func dietaryEnergy() async throws -> DietaryEnergy {
        
        let statisticsCollection = try await dailyStatistics(from: startDate, to: date)

        var samples: [MaintenanceSample] = []
        for i in 0...interval.numberOfDays-1 {
            let date = date.moveDayBy(-i)
            guard let statistics = statisticsCollection.statistics(for: date),
                  let sumQuantity = statistics.sumQuantity()
            else {
                samples.append(.init(type: .healthKit))
                continue
            }
            let value = sumQuantity.doubleValue(for: unit)
            samples.append(.init(type: .healthKit, value: value))
        }
        
        var dietaryEnergy = DietaryEnergy(samples: samples)
        dietaryEnergy.fillEmptyValuesWithAverages()
        
        return dietaryEnergy
    }
}
