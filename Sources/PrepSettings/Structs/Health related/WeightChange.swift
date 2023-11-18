import Foundation

public struct WeightChange: Hashable, Codable {
    public let current: MaintenanceSample?
    public let previous: MaintenanceSample?
    
    public init(current: MaintenanceSample? = nil, previous: MaintenanceSample? = nil) {
        self.current = current
        self.previous = previous
    }
}

extension WeightChange: CustomStringConvertible {
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
public extension WeightChange {
    var delta: Double? {
        guard let current, let previous else { return nil }
        return current.value - previous.value
    }
}
