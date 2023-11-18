import Foundation

public struct MaintenanceSample: Hashable, Codable {
    var type: AdaptiveDataType
    var movingAverageInterval: HealthInterval?
    var averagedValues: [Int: Double]?
    var value: Double?

    public init(
        type: AdaptiveDataType,
        movingAverageInterval: HealthInterval? = nil,
        averagedValues: [Int: Double]? = nil,
        value: Double? = nil
    ) {
        self.type = type
        self.movingAverageInterval = movingAverageInterval
        self.averagedValues = averagedValues
        self.value = value
    }
}

extension MaintenanceSample: CustomStringConvertible {
    public var description: String {
        "\(value?.cleanAmount ?? "nil") (\(type.name))"
    }
}
