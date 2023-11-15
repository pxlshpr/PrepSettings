import HealthKit
import PrepShared

struct HealthKitQuantityRequest {
    let quantityType: QuantityType
    let healthKitUnit: HKUnit
    let date: Date
    
    init(
        _ type: QuantityType,
        _ unit: HKUnit,
        _ date: Date
    ) {
        self.quantityType = type
        self.healthKitUnit = unit
        self.date = date
    }
}

extension Array where Element == Double {
    var averageValue: Double? {
        guard !isEmpty else { return nil }
        let sum = self
            .reduce(0, +)
        return sum / Double(count)
    }
}
extension Array where Element == Quantity {
    var valuesGroupedByDate: [[Double]] {
        let withDates = self.filter { $0.date != nil }
        return Dictionary(grouping: withDates) { $0.date!.startOfDay }
            .map { $0.value.map { $0.value } }
    }
}

extension HealthKitQuantityRequest {
    
    func averageValue(
        for date: Date,
        asMovingAverageWithNumberOfPriorDays days: Int = 0
    ) async throws -> Double? {
        
        //TODO: Write this properly
        /// [ ] Get all quantities from start of earliest day to end of last day (provided date)
        /// [ ] Now average out all the days and get an array of the daily values (should be `days` long)
        /// [ ] Now average this value out so that we get the moving average value
        /// [x] Now incorporate both this and weight(on:) in a single function that gets provided an `asMovingAverage` parameter
        /// [x] Now test that this works
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "startDate >= %@", date.moveDayBy(-days).startOfDay as NSDate),
            NSPredicate(format: "startDate <= %@", date.endOfDay as NSDate)
        ])
        
        let quantities = try await quantities(matching: predicate)
        let groupedByDate = quantities.valuesGroupedByDate
        var dailyAverages: [Double] = []
        for dailyValues in groupedByDate {
            guard let dailyAverage = dailyValues.averageValue else { continue }
            dailyAverages.append(dailyAverage)
        }
        return dailyAverages.averageValue
    }
    
    func averageValue(on date: Date) async throws -> Double? {
        try await averageValue(for: date)
    }
}

extension HealthKitQuantityRequest {
    
    func adaptiveWeightData() async throws -> AdaptiveWeightData? {
        
        func weight(for date: Date) async throws -> Double? {
            try await averageValue(
                for: date,
                asMovingAverageWithNumberOfPriorDays: 6
            )
        }
        
        let current: AdaptiveDataPoint? = if let weight = try await weight(for: date) {
            AdaptiveDataPoint(.healthKit, weight)
        } else { nil }
        
        let previous: AdaptiveDataPoint? = if let weight = try await weight(for: date.moveDayBy(-7)) {
            AdaptiveDataPoint(.healthKit, weight)
        } else { nil }
        
        return AdaptiveWeightData(current: current, previous: previous)
    }
}

extension HealthKitQuantityRequest {
    func mostRecentOrEarliestAvailable() async throws -> Quantity? {
        guard let mostRecent = try await mostRecent() else {
            return try await earliestAvailable()
        }
        return mostRecent
    }

    func mostRecent() async throws -> Quantity? {
        try await firstQuantity(
            matching: NSPredicate(format: "startDate <= %@", date as NSDate),
            sortDescriptors: [SortDescriptor(\.startDate, order: .reverse)]
        )
    }
    
    func earliestAvailable() async throws -> Quantity? {
        try await firstQuantity(
            sortDescriptors: [SortDescriptor(\.startDate, order: .forward)]
        )
    }
}

extension HealthKitQuantityRequest {
    
    var typeIdentifier: HKQuantityTypeIdentifier { quantityType.healthKitTypeIdentifier }

    func requestPersmissions() async throws {
        try await HealthStore.requestPermissions(quantityTypeIdentifiers: [typeIdentifier])
    }

    func samples(
        matching predicate: NSPredicate? = nil,
        sortDescriptors: [SortDescriptor<HKQuantitySample>] = [],
        limit: Int? = nil
    ) async throws -> [HKQuantitySample] {
        try await requestPersmissions()

        let type = HKSampleType.quantityType(forIdentifier: typeIdentifier)!
        let samplePredicates = [HKSamplePredicate.quantitySample(type: type, predicate: predicate)]
        
        let asyncQuery = HKSampleQueryDescriptor(
            predicates: samplePredicates,
            sortDescriptors: sortDescriptors,
            limit: limit
        )

        return try await asyncQuery.result(for: HealthStore.store)
    }
    
    func quantities(
        matching predicate: NSPredicate? = nil,
        sortDescriptors: [SortDescriptor<HKQuantitySample>] = []
    ) async throws -> [Quantity] {
        try await samples(matching: predicate, sortDescriptors: sortDescriptors)
            .map { $0.asQuantity(in: healthKitUnit) }
    }

    func firstQuantity(
        matching predicate: NSPredicate? = nil,
        sortDescriptors: [SortDescriptor<HKQuantitySample>] = []
    ) async throws -> Quantity? {
        try await samples(
            matching: predicate,
            sortDescriptors: sortDescriptors,
            limit: 1
        )
        .first?
        .asQuantity(in: healthKitUnit)
    }
}

extension HKQuantitySample {
    func asQuantity(in healthKitUnit: HKUnit) -> Quantity {
        let quantity = quantity.doubleValue(for: healthKitUnit)
        let date = startDate
        return Quantity(value: quantity, date: date)
    }
}
