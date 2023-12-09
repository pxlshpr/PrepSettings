import Foundation

//public struct MaintenanceSample: Hashable, Codable {
//    var type: MaintenanceSampleType
//    var movingAverageInterval: HealthInterval?
//    var averagedValues: [Int: Double]?
//    var value: Double?
//
//    public init(
//        type: MaintenanceSampleType,
//        movingAverageInterval: HealthInterval? = nil,
//        averagedValues: [Int: Double]? = nil,
//        value: Double? = nil
//    ) {
//        self.type = type
//        self.movingAverageInterval = movingAverageInterval
//        self.averagedValues = averagedValues
//        self.value = value
//    }
//}
//
//extension MaintenanceSample: CustomStringConvertible {
//    public var description: String {
//        "\(value?.cleanAmount ?? "nil") (\(type.name))"
//    }
//}

//extension MaintenanceSample {
//    mutating func fill(using request: HealthKitQuantityRequest) async throws {
//        if let sample = try await request.daySample(movingAverageInterval: self.movingAverageInterval)
//        {
//            type = .healthKit
//            averagedValues = sample.movingAverageValues
//            value = sample.value
//        } else {
//            averagedValues = nil
//            value = nil
//        }
//    }
//}
