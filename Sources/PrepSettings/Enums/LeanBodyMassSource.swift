import Foundation
import PrepShared

public enum LeanBodyMassSource: Int16, Codable, CaseIterable {
    case healthKit = 1
    case equation
    case fatPercentage
    case userEntered
}

public extension LeanBodyMassSource {
    
    var isCalculated: Bool {
        switch self {
        case .equation, .fatPercentage: true
        default:                        false
        }
    }
    
    var params: [HealthType] {
        switch self {
        case .equation:
            [.sex, .weight, .height]
        case .fatPercentage:
            [.weight]
        default:
            []
        }
    }
}

extension LeanBodyMassSource: Pickable {
    public var menuImage: String {
        switch self {
        case .healthKit:        "heart.fill"
        case .equation:         "function"
        case .fatPercentage:    "function"
        case .userEntered:      ""
        }
    }
    
    public var pickedTitle: String { menuTitle }

    public var menuTitle: String {
        switch self {
        case .equation:         "Equation"
        case .healthKit:        "Health app"
        case .fatPercentage:    "Fat percentage"
        case .userEntered:      "Entered manually"
        }
    }
    
    public static var `default`: LeanBodyMassSource { .equation }
}
