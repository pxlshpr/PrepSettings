import Foundation

public struct Quantity: Hashable, Codable {
    public var value: Double
    public var date: Date?
    
    public init(value: Double, date: Date? = nil) {
        self.value = value
        self.date = date
    }
}

extension Array where Element == Quantity {
    var valuesGroupedByDate: [Date: [Quantity]] {
        let withDates = self.filter { $0.date != nil }
        return Dictionary(grouping: withDates) { $0.date!.startOfDay }
    }
}

import HealthKit

extension HKQuantitySample {
    func asQuantity(in healthKitUnit: HKUnit) -> Quantity {
        let quantity = quantity.doubleValue(for: healthKitUnit)
        let date = startDate
        return Quantity(value: quantity, date: date)
    }
}
