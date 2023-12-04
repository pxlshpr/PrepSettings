import Foundation
import PrepShared

public enum HealthIntervalType: Int16, Codable, CaseIterable {
    case average = 1
    case sameDay
    case previousDay
}

extension HealthIntervalType {
    var detail: String {
        switch self {
        case .average:
            "Use the daily average of a specified period before this day"
        case .sameDay:
            "Use the value for this date"
        case .previousDay:
            "Use the value for the day before this date"
        }
    }
}

extension HealthIntervalType: Pickable {

    public var pickedTitle: String {
        switch self {
        case .average:      "Daily average"
        case .sameDay:      "Same day"
        case .previousDay:  "Previous day"
        }
    }
    
    public var menuTitle: String {
        pickedTitle
    }
    
    public static var `default`: HealthIntervalType { .average }
}
