import Foundation
import PrepShared

public enum HealthSource: Int16, Codable, CaseIterable {
    case healthKit = 1
    case userEntered
}

public extension HealthSource {
    var name: String {
        switch self {
        case .healthKit:    "Health app"
        case .userEntered:  "Entered manually"
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
}
