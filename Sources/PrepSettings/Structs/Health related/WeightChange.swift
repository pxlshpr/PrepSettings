import Foundation
import PrepShared

public struct WeightChange: Hashable, Codable {
    public let current: MaintenanceSample
    public let previous: MaintenanceSample
    
    public init(current: MaintenanceSample = .init(type: .userEntered), previous: MaintenanceSample = .init(type: .userEntered)) {
        self.current = current
        self.previous = previous
    }
}

extension WeightChange: CustomStringConvertible {
    public var description: String {
        var string = ""
        string += "[current] → \(current.description)\n"
        string += "[previous] → \(previous.description)\n"
        if let delta {
            string += "Δ \(delta)"
        }
        return string
    }
}
public extension WeightChange {
    var delta: Double? {
        guard 
            let currentValue = current.value,
            let previousValue = previous.value
        else { return nil }
        return currentValue - previousValue
    }
    
    var deltaEquivalentEnergyInKcal: Double? {
        guard let delta else { return nil }
//        454 g : 3500 kcal
//        delta : x kcal
        return (3500 * delta) / BodyMassUnit.lb.convert(1, to: .kg)
    }
}
