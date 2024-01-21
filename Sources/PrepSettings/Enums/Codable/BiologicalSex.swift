//import Foundation
//import PrepShared
//
//public enum BiologicalSex: Int, Codable, CaseIterable {
//    case female = 1
//    case male
//    case notSet
//}
//
//public extension BiologicalSex {
//    var name: String {
//        switch self {
//        case .female:   "Female"
//        case .male:     "Male"
//        case .notSet:   NotSetString
//        }
//    }
//}
//
//extension BiologicalSex: Pickable {
//    public var pickedTitle: String { self.name }
//    public var menuTitle: String { self.name }
//    public static var `default`: BiologicalSex { .notSet }
//}
