import Foundation
import PrepShared

let DefaultAge = 20
let DefaultDateOfBirth = Date.now.moveYearBy(-DefaultAge)
let DefaultWeightInKg = 62.0
let DefaultHeightInCm = 170.0
let DefaultFatPercentage = 22.0

public enum AgeSource: Int16, Codable, CaseIterable {
    case healthKit = 1
    case userEnteredDateOfBirth
    case userEnteredAge
}

public extension AgeSource {
    var name: String {
        switch self {
        case .healthKit:                "Health app"
        case .userEnteredDateOfBirth:   "Date of birth"
        case .userEnteredAge:           "Entered manually"
        }
    }
    
    var menuImage: String {
        switch self {
        case .healthKit:                "heart.fill"
        case .userEnteredDateOfBirth:   "calendar"
        case .userEnteredAge:           ""
        }
    }
    
    var defaultValue: Int {
        DefaultAge
    }
}

extension AgeSource: Pickable {
    public var pickedTitle: String { name }
    public var menuTitle: String { name }
    public static var `default`: AgeSource { .userEnteredDateOfBirth }
}

