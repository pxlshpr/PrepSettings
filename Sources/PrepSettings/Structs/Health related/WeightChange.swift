import Foundation
import PrepShared

public struct WeightChange: Hashable, Codable {
    public var current: MaintenanceSample
    public var previous: MaintenanceSample
    
    public init(
        current: MaintenanceSample = .init(type: .healthKit, movingAverageInterval: .init(1, .week)),
        previous: MaintenanceSample = .init(type: .healthKit, movingAverageInterval: .init(1, .week))
    ) {
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
    
    var isEmpty: Bool {
        current.value == nil || previous.value == nil
    }
}
