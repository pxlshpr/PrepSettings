import Foundation
import PrepShared

public enum LeanBodyMassEquation: Int16, Codable, CaseIterable {
    case boer = 1
    case james
    case hume
}

extension LeanBodyMassEquation: Pickable {
    
    public var pickedTitle: String {
        switch self {
        case .boer:     "Boer • 1984"
        case .james:    "James • 1976"
        case .hume:     "Hume • 1966"
        }
    }
    
    public var menuTitle: String {
        switch self {
        case .boer:     "Boer"
        case .james:    "James"
        case .hume:     "Hume"
        }
    }
    
    public static var `default`: LeanBodyMassEquation { .boer }
}

public extension LeanBodyMassEquation {
    func usesHealthKit(in health: Health) -> Bool {
        for param in self.params {
            switch param {
            case .sex:
                if health.usesHealthKitForSex { return true }
            case .weight:
                if health.usesHealthKitForWeight { return true }
            case .height:
                if health.usesHealthKitForHeight { return true }
            default:
                /// Remaining health types are not possible parameters
                continue
            }
        }
        return false
    }
}
