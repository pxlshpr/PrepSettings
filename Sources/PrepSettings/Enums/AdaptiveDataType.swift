import SwiftUI
import PrepShared

public enum AdaptiveDataType: Int, Hashable, Codable {
    case healthKit = 1
    case userEntered
    case averaged
}

public extension AdaptiveDataType {
    static func options(for component: AdaptiveDataComponent) -> [AdaptiveDataType] {
        switch component {
        case .weight:           [.healthKit, .userEntered]
        case .dietaryEnergy:    allCases
        }
    }
}
extension AdaptiveDataType: Pickable {
    public var pickedTitle: String { name }
    public var menuTitle: String { name }
    public static var `default`: AdaptiveDataType { .userEntered }
}

extension AdaptiveDataType: GenericSource {
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
