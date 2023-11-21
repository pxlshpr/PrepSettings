import SwiftUI
import PrepShared

public enum MaintenanceDietaryEnergySampleType: Int, Hashable, Codable {
    case healthKit = 1
    case averaged
    case backend
}
