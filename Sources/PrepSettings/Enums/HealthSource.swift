import Foundation
import PrepShared

public enum HealthSource: Int16, Codable, CaseIterable {
    case healthKit = 1
    case userEntered
}

public extension HealthSource {
    var name: String {
        switch self {
        case .healthKit:    "Apple Health"
        case .userEntered:  "Custom"
        }
    }
    
    var menuImage: String {
        switch self {
        case .healthKit:    "heart.fill"
        case .userEntered:  ""
        }
    }
}

extension HealthSource: Pickable {
    public var pickedTitle: String { name }
    public var menuTitle: String { name }
    public static var `default`: HealthSource { .userEntered }
    public var description: String? {
        switch self {
        case .healthKit:
//            "Use the latest weight data from Apple Health"
//            "Use the most recent weight data from Apple Health"
            "Use weight data from Apple Health"
        case .userEntered:
            "Use a custom entered value"
        }
    }
}
