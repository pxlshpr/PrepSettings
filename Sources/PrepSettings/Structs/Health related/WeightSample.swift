import Foundation

public struct WeightSample: Hashable, Codable {
    var value: Double?
    var movingAverageInterval: HealthInterval?
    var movingAverageValues: [Int: Double]?

    public init(
        movingAverageInterval: HealthInterval? = DefaultWeightMovingAverageInterval,
//        movingAverageInterval: HealthInterval? = nil,
        movingAverageValues: [Int: Double]? = nil,
        value: Double? = nil
    ) {
        self.movingAverageInterval = movingAverageInterval
        self.movingAverageValues = movingAverageValues
        self.value = value
    }
}

extension WeightSample {
    mutating func fill(using request: HealthKitQuantityRequest) async throws {
        if let sample = try await request.daySample(movingAverageInterval: self.movingAverageInterval)
        {
            movingAverageValues = sample.movingAverageValues
            value = sample.value
        } else {
            movingAverageValues = nil
            value = nil
        }
    }
}
