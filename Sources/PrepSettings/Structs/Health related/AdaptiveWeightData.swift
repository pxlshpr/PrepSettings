import Foundation

public struct AdaptiveWeightData: Hashable, Codable {
    public let current: AdaptiveDataPoint?
    public let previous: AdaptiveDataPoint?
}

extension AdaptiveWeightData: CustomStringConvertible {
    public var description: String {
        var string = ""
        if let point = current {
            string += "[current] → \(point.description)\n"
        } else {
            string += "[current] → nil\n"
        }
        if let point = previous {
            string += "[previous] → \(point.description)\n"
        } else {
            string += "[previous] → nil\n"
        }
        if let delta {
            string += "Δ \(delta)"
        }
        return string
    }
}
public extension AdaptiveWeightData {
    var delta: Double? {
        guard let current, let previous else { return nil }
        return current.value - previous.value
    }
}
