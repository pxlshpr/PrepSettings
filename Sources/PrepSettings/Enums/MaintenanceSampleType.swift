import SwiftUI
import PrepShared

public enum MaintenanceSampleType: Int, Hashable, Codable {
    case healthKit = 1
    case userEntered
    case averaged
}

public extension MaintenanceSampleType {
    static func options(for component: MaintenanceComponent) -> [MaintenanceSampleType] {
        switch component {
        case .weight:           [.healthKit, .userEntered]
        case .dietaryEnergy:    allCases
        }
    }
}
extension MaintenanceSampleType: Pickable {
    public var pickedTitle: String { name }
    public var menuTitle: String { name }
    public static var `default`: MaintenanceSampleType { .userEntered }
}

extension MaintenanceSampleType: GenericSource {
    public var isHealth: Bool {
        switch self {
        case .healthKit:    true
        default:            false
        }
    }
    public var isManual: Bool {
        switch self {
        case .userEntered:    true
        default:            false
        }
    }
}

public extension MaintenanceSampleType {
    var systemImage: String {
        switch self {
//        case .averaged:     "chart.line.flattrend.xyaxis"
        case .averaged:     "equal"
        case .healthKit:    "heart.fill"
        case .userEntered:  "pencil"
        }
    }
    
    var name: String {
        switch self {
        case .averaged:     "Average value"
        case .healthKit:    "Health app"
        case .userEntered:  "Entered manually"
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .averaged:     .white
        case .healthKit:    .pink
        case .userEntered:  .white
        }
    }

    var backgroundColor: Color {
        switch self {
        case .averaged:     .gray
        case .healthKit:    .white
        case .userEntered:  .accentColor
        }
    }
    
    var strokeColor: Color {
        switch self {
        case .averaged:     .clear
        case .healthKit:    .gray
        case .userEntered:  .clear
        }
    }
}
