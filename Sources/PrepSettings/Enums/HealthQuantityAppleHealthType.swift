import Foundation
import PrepShared

public enum HealthQuantityAppleHealthType: Int16, Codable, CaseIterable {
    case latestAverageOfDay = 1
    case latestEntry
}

public extension HealthQuantityAppleHealthType {
    var name: String {
        switch self {
        case .latestAverageOfDay:   "Latest Average of Day"
        case .latestEntry:          "Latest Entry"
        }
    }
}

extension HealthQuantityAppleHealthType: Pickable {
    public var pickedTitle: String { name }
    public var menuTitle: String { name }
    public static var `default`: HealthQuantityAppleHealthType { .latestAverageOfDay }
}
