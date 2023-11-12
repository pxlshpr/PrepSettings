import Foundation
import PrepShared

public enum HealthType: CaseIterable {
    case energyBurn
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
            .energyBurn,
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
//        case .energyBurn:       "daily energy burn"
        case .energyBurn:       "energy expenditure"
        case .restingEnergy:    "resting energy"
        case .activeEnergy:     "active energy"
        case .sex:              "biological sex"
        case .age:              "age"
        case .weight:           "weight"
        case .leanBodyMass:     "lean body mass"
        case .fatPercentage:    "fat %"
        case .height:           "height"
        case .pregnancyStatus:  "pregnancy status"
        case .isSmoker:         "smoker"
        }
    }
    
    var name: String {
        switch self {
//        case .energyBurn:       "Daily Energy Burn"
        case .energyBurn:       "Energy Expenditure"
        case .restingEnergy:    "Resting Energy"
        case .activeEnergy:     "Active Energy"
        case .sex:              "Biological Sex"
        case .age:              "Age"
        case .weight:           "Weight"
        case .leanBodyMass:     "Lean Body Mass"
        case .fatPercentage:    "Fat Percentage"
        case .height:           "Height"
        case .pregnancyStatus:  "Pregnancy Status"
        case .isSmoker:         "Smoker"
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
        case .energyBurn:
            "Your daily energy burn is used in energy goals targeting a desired weight change."
        case .sex:
            "Used to calculate resting energy or lean body mass. Also used to pick daily values for micronutrients."
        case .age:
            "Used to calculate resting energy or pick daily values for micronutrients."
        case .leanBodyMass:
            "Used to create goals and calculate resting energy."
        case .weight, .height:
            "Used to calculate resting energy or lean body mass."
        default:
            nil
        }
    }
}
