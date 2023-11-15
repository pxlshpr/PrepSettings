import Foundation

public enum AdaptiveDataComponent: Int, Hashable, Codable {
    case weight = 1
    case dietaryEnergy
}

public extension AdaptiveDataComponent {
    var name: String {
        switch self {
        case .weight:           "Weight"
        case .dietaryEnergy:    "Dietary Energy"
        }
    }
}
