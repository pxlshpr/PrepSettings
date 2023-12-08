import Foundation
import PrepShared

protocol GenericSource: Pickable {
    var isHealth: Bool { get }
    var isManual: Bool { get }
    var placeholder: String { get }
}

extension GenericSource {
    var placeholder: String {
        switch isHealth {
        case true:  "Unavailable"
        case false: "Not Set"
        }
    }
}

extension HealthSource: GenericSource {
    var isHealth: Bool { self == .healthKit }
    var isManual: Bool { self == .userEntered }
}

extension AgeSource: GenericSource {
    var isHealth: Bool { self == .healthKit }
    var isManual: Bool { self == .userEnteredAge }
}

extension RestingEnergySource: GenericSource {
    var isHealth: Bool { self == .healthKit }
    var isManual: Bool { self == .userEntered }
}

extension ActiveEnergySource: GenericSource {
    var isHealth: Bool { self == .healthKit }
    var isManual: Bool { self == .userEntered }
    var placeholder: String {
        switch self {
        case .healthKit:        "Unavailable"
        case .activityLevel:    "Requires resting energy"
        case .userEntered:      "Not Set"
        }
    }
}

extension LeanBodyMassSource: GenericSource {
    var isHealth: Bool { self == .healthKit }
    var isManual: Bool { self == .userEntered }
    var placeholder: String {
        switch self {
        case .healthKit:        "Unavailable"
        case .userEntered:      "Not Set"
        case .equation:         "Unable to calculate" //"Requires health details"
        case .fatPercentage:    "Requires fat percentage"
        }
    }
}
