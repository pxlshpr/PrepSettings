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
        case false: "Not set"
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
        case .activityLevel:    "Resting energy required"
        case .userEntered:      "Not set"
        }
    }
}

extension LeanBodyMassSource: GenericSource {
    var isHealth: Bool { self == .healthKit }
    var isManual: Bool { self == .userEntered }
    var placeholder: String {
        switch self {
        case .healthKit:        "Unavailable"
        case .userEntered:      "Not set"
        case .equation:         "Health data required"
        case .fatPercentage:    "Fat percentage required"
        }
    }
}
