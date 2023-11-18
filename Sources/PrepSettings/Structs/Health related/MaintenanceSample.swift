import Foundation

public struct MaintenanceSample: Hashable, Codable {
    var type: AdaptiveDataType
    var averagedValues: [Int: Double]?
    var value: Double

    init(
        type: AdaptiveDataType,
        averagedValues: [Int: Double]? = nil,
        value: Double
    ) {
        self.type = type
        self.averagedValues = averagedValues
        self.value = value
    }
}

extension MaintenanceSample: CustomStringConvertible {
    public var description: String {
        "\(value.cleanAmount) (\(type.name))"
    }
}
