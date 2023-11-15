import Foundation

public struct AdaptiveDataPoint: Hashable, Codable {
    let type: AdaptiveDataType
    let value: Double

    init(type: AdaptiveDataType, value: Double) {
        self.type = type
        self.value = value
    }

    init(_ type: AdaptiveDataType, _ value: Double) {
        self.type = type
        self.value = value
    }
}

extension AdaptiveDataPoint: CustomStringConvertible {
    public var description: String {
        "\(value.cleanAmount) (\(type.name))"
    }
}
