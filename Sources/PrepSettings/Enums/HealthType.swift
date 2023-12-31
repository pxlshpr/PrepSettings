import Foundation
import PrepShared

public enum HealthType: CaseIterable {
    case maintenance
    case restingEnergy
    case activeEnergy
    case sex
    case age
    case weight
    case leanBodyMass
    case fatPercentage
    case height
    case pregnancyStatus
    case isSmoker
}

public extension HealthType {
    static var summaryTypes: [HealthType] {
        [
            .maintenance,
            .age,
            .sex,
            .height,
            .weight,
            .leanBodyMass,
            .pregnancyStatus,
            .isSmoker
        ]
    }
}

public extension HealthType {
    var canBeRemoved: Bool {
        switch self {
        case .restingEnergy, .activeEnergy, .fatPercentage:
            false
        default:
            true
        }
    }
}

public extension HealthType {
    
    var usesPrecision: Bool {
        switch self {
        case .weight, .leanBodyMass, .fatPercentage, .height: true
        default: false
        }
    }
    
    var abbreviation: String {
        switch self {
        case .maintenance:    "maintenance energy"
        case .restingEnergy:        "resting energy"
        case .activeEnergy:         "active energy"
        case .sex:                  "biological sex"
        case .age:                  "age"
        case .weight:               "weight"
        case .leanBodyMass:         "lean body mass"
        case .fatPercentage:        "fat %"
        case .height:               "height"
        case .pregnancyStatus:      "pregnancy status"
        case .isSmoker:             "smoker"
        }
    }
    
    var name: String {
        switch self {
        case .maintenance:    "Maintenance Energy"
        case .restingEnergy:        "Resting Energy"
        case .activeEnergy:         "Active Energy"
        case .sex:                  "Biological Sex"
        case .age:                  "Age"
        case .weight:               "Weight"
        case .leanBodyMass:         "Lean Body Mass"
        case .fatPercentage:        "Fat Percentage"
        case .height:               "Height"
        case .pregnancyStatus:      "Pregnancy Status"
        case .isSmoker:             "Smoker"
        }
    }

    var nameWhenSetting: String {
        switch self {
        case .isSmoker: "Smoking Status"
        default: name
        }
    }
    
    var usesUnit: Bool {
        switch self {
        case .sex, .age, .fatPercentage: false
        default: true
        }
    }
    
    var systemImage: String? {
        switch self {
        case .restingEnergy: "bed.double.fill"
        case .activeEnergy: "figure.walk.motion"
        default: nil
        }
    }
}

public extension BodyMassType {
    var healthType: HealthType {
        switch self {
        case .weight:   .weight
        case .leanMass: .leanBodyMass
        }
    }
}

extension HealthType {
    var reason: String? {
        switch self {
        case .restingEnergy:
            "The estimated energy you burn when your body is completely at rest."
        case .activeEnergy:
            "The estimated energy you burn while being active."
        case .maintenance:
//            "Your daily energy burn is used in energy goals targeting a desired weight change."
            "The daily energy needed to maintain your weight. Used to create relative energy goals."
        case .sex:
            "Used to calculate resting energy or lean body mass. Also used as a criteria when choosing daily values for micronutrients."
        case .age:
            "Used to calculate resting energy. Also used as a criteria when choosing daily values for micronutrients."
        case .leanBodyMass:
            "Used to create goals and calculate resting energy."
        case .height:
            "Used to calculate resting energy or lean body mass."
        case .weight:
            "Used in maintenance energy and lean body mass calculations."
        default:
            nil
        }
    }
}
