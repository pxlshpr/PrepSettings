import Foundation

public enum WeightChangeType: Int, Codable, CaseIterable {
    case usingWeights
    case userEntered
}

public extension WeightChangeType {
    var name: String {
        switch self {
        case .usingWeights: "Calculated"
        case .userEntered:  "Custom"
        }
    }
}
