import Foundation
import PrepShared

public enum RestingEnergySource: Int16, Codable, CaseIterable {
    case healthKit = 1
    case equation
    case userEntered
}

extension RestingEnergySource: Pickable {
    
    public var pickedTitle: String {
        menuTitle
    }
    
    public var menuTitle: String {
        switch self {
        case .healthKit:    "Health app"
        case .equation:     "Equation"
        case .userEntered:  "Entered manually"
        }
    }
    
    public var menuImage: String {
        switch self {
        case .healthKit:    "heart.fill"
        case .equation:     "function"
        case .userEntered:  ""
        }
    }
    
    public static var `default`: RestingEnergySource { .equation }
}
