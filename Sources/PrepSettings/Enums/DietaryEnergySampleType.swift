import SwiftUI
import PrepShared

public enum DietaryEnergySampleType: Int, Hashable, Codable, CaseIterable {
    case logged = 1
    case healthKit
    case average
    case notConsumed
    case userEntered
}

public extension DietaryEnergySampleType {
    
    var name: String {
        switch self {
        case .healthKit:    "Apple Health"
        case .average:      "Average"
        case .logged:       "Logged"
        case .notConsumed:  "Not Consumed"
        case .userEntered:  "Entered Manually"
        }
    }
}
