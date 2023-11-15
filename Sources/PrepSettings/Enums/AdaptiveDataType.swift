import SwiftUI
import PrepShared

public enum AdaptiveDataType: Int, Hashable, Codable {
    case healthKit = 1
    case userEntered
    case averaged
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
