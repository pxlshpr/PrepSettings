import Foundation
import PrepShared

public enum RestingEnergyEquation: Int16, Hashable, Codable, CaseIterable {
    case katchMcardle = 1
    case henryOxford
    case mifflinStJeor
    case schofield
    case cunningham
    case rozaShizgal
    case harrisBenedict
}

extension RestingEnergyEquation: Pickable {
    public var pickedTitle: String { name }
    public var menuTitle: String { name }
    public static var `default`: RestingEnergyEquation { .katchMcardle }
    public var detail: String? { year }
}

public extension RestingEnergyEquation {
    var name: String {
        switch self {
        case .schofield:        "Schofield"
        case .henryOxford:      "Henry Oxford"
        case .harrisBenedict:   "Harris-Benedict"
        case .cunningham:       "Cunningham"
        case .rozaShizgal:      "Roza-Shizgal"
        case .mifflinStJeor:    "Mifflin-St. Jeor"
        case .katchMcardle:     "Katch-McArdle"
        }
    }
    
    var year: String {
        switch self {
        case .schofield:        "1985"
        case .henryOxford:      "2005"
        case .harrisBenedict:   "1919"
        case .cunningham:       "1980"
        case .rozaShizgal:      "1984"
        case .mifflinStJeor:    "1990"
        case .katchMcardle:     "1996"
        }
    }
}

public extension RestingEnergyEquation {
    
    static var inOrderOfYear: [RestingEnergyEquation] {
        [.henryOxford, .katchMcardle, .mifflinStJeor, .schofield, .rozaShizgal, .cunningham, .harrisBenedict]
    }
    
    static var latest: [RestingEnergyEquation] {
        [.henryOxford, .katchMcardle, .mifflinStJeor, .schofield]
    }

    static var legacy: [RestingEnergyEquation] {
        [.rozaShizgal, .cunningham, .harrisBenedict]
    }

    
    var requiresHeight: Bool {
        switch self {
        case .henryOxford, .schofield, .katchMcardle, .cunningham:
            false
        default:
            true
        }
    }
   
    var usesLeanBodyMass: Bool {
        switch self {
        case .katchMcardle, .cunningham:
            true
        default:
            false
        }
    }

    var params: [HealthType] {
        switch self {
        case .katchMcardle, .cunningham:
            [.leanBodyMass]
        case .henryOxford, .schofield:
            [.sex, .age, .weight]
        case .mifflinStJeor, .rozaShizgal, .harrisBenedict:
            [.sex, .age, .weight, .height]
        }
    }
}

public extension RestingEnergyEquation {
    func usesHealthKit(in health: HealthDetails) -> Bool {
        for param in self.params {
            switch param {
            case .sex:          if health.usesHealthKitForSex { return true }
            case .age:          if health.usesHealthKitForAge { return true }
            case .weight:       if health.usesHealthKitForWeight { return true }
            case .leanBodyMass: if health.usesHealthKitForLeanBodyMass { return true }
            case .height:       if health.usesHealthKitForHeight { return true }
            default:
                /// Remaining health types are not possible parameters
                continue
            }
        }
        return false
    }
}
