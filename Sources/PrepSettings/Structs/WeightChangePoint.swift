//import Foundation
//
//public struct WeightChangePoint: Hashable, Codable {
//    
//    public var date: Date
//    public var kg: Double?
//    
//    public var movingAverageInterval: HealthInterval? = .init(7, .day)
//
//    init(
//        date: Date,
//        kg: Double? = nil,
//        movingAverageInterval: HealthInterval? = .init(7, .day)
//    ) {
//        self.date = date
//        self.kg = kg
//        self.movingAverageInterval = movingAverageInterval
//    }
//}
//
//extension Array where Element == HealthDetails.Weight {
//    var average: Double? {
//        let values = self
//            .compactMap { $0.weightInKg }
//        guard !values.isEmpty else { return nil }
//        let sum = values.reduce(0) { $0 + $1 }
//        return Double(sum) / Double(values.count)
//    }
//}
