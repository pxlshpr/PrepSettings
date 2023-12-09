import Foundation
import PrepShared

public enum WeightChangeType: Int, Codable, CaseIterable {
    case usingWeights
    case userEntered
}

public extension WeightChangeType {
    var name: String {
        switch self {
        case .usingWeights: "Calculated"
        case .userEntered:  "Custom"
        }
    }
}

extension WeightChangeType: Pickable {
    public var pickedTitle: String {
        name
    }
    
    public var menuTitle: String {
        name
    }
    
    public var description: String? {
        switch self {
        case .usingWeights:
            "Use the current and previous weights to determine your weight change"
        case .userEntered:
            "Use a custom entered value"
        }
    }
    
    public static var `default`: WeightChangeType {
        .usingWeights
    }
}
