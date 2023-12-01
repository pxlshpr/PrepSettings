import SwiftUI
import PrepShared

public enum DietaryEnergySampleType: Int, Hashable, Codable, CaseIterable {
    case logged = 1
    case healthKit
    case average
//    case notConsumed
    case userEntered
}

public extension DietaryEnergySampleType {
    
    static var userCases: [DietaryEnergySampleType] {
        [.logged, .healthKit, .userEntered]
    }
    
    var name: String {
        switch self {
        case .healthKit:    "Apple Health"
        case .average:      "Average"
        case .logged:       "Log"
//        case .notConsumed:  "Not Consumed"
        case .userEntered:  "Custom"
        }
    }
}
