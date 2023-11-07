import Foundation
import PrepShared
import PrepSettings

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

extension BiometricSource: GenericSource {
    var isHealth: Bool { self == .health }
    var isManual: Bool { self == .userEntered }
}

extension AgeSource: GenericSource {
    var isHealth: Bool { self == .health }
    var isManual: Bool { self == .userEnteredAge }
}

extension RestingEnergySource: GenericSource {
    var isHealth: Bool { self == .health }
    var isManual: Bool { self == .userEntered }
}

extension ActiveEnergySource: GenericSource {
    var isHealth: Bool { self == .health }
    var isManual: Bool { self == .userEntered }
    var placeholder: String {
        switch self {
        case .health:           "Unavailable"
        case .activityLevel:    "Resting energy required"
        case .userEntered:      "Not set"
        }
    }
}

extension LeanBodyMassSource: GenericSource {
    var isHealth: Bool { self == .health }
    var isManual: Bool { self == .userEntered }
    var placeholder: String {
        switch self {
        case .health:           "Unavailable"
        case .userEntered:      "Not set"
        case .equation:         "Biometrics required"
        case .fatPercentage:    "Fat percentage required"
        }
    }
}
