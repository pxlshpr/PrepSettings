import Foundation

public enum MaintenanceComponent: Int, Hashable, Codable, CaseIterable {
    case weight = 1
    case dietaryEnergy
}

public extension MaintenanceComponent {
    var name: String {
        switch self {
        case .weight:           "Weight"
        case .dietaryEnergy:    "Dietary Energy"
        }
    }
}
