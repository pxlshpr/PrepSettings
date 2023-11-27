import SwiftUI
import PrepShared

public enum MaintenanceDietaryEnergySampleType: Int, Hashable, Codable, CaseIterable {
    case logged = 1
    case healthKit
    case average
    case notConsumed
}

extension MaintenanceDietaryEnergySampleType {
    var name: String {
        switch self {
        case .healthKit:    "Apple Health"
        case .average:      "Average"
        case .logged:       "Logged"
        case .notConsumed:  "Not Consumed"
        }
    }
}
