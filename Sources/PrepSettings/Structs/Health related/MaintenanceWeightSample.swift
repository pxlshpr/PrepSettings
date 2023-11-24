import Foundation

public struct MaintenanceWeightSample: Hashable, Codable {
    var value: Double?
    var movingAverageInterval: HealthInterval?
    var movingAverageValues: [Int: Double]?

    public init(
        movingAverageInterval: HealthInterval? = nil,
        averagedValues: [Int: Double]? = nil,
        value: Double? = nil
    ) {
        self.movingAverageInterval = movingAverageInterval
        self.movingAverageValues = averagedValues
        self.value = value
    }
}

extension MaintenanceWeightSample {
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
