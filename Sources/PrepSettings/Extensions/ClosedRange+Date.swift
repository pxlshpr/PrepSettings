//import Foundation
//
//extension Date {
//    var shortMonth: String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "MMM"
//        return formatter.string(from: self)
//    }
//}
//extension ClosedRange where Bound == Date {
//    var string: String {
//        
//        let sameYear = lowerBound.year == upperBound.year
//        let sameMonth = lowerBound.month == upperBound.month
//        
//        let upperYear = upperBound.year == Date.now.year ? "" : " \(upperBound.year)"
//        let lowerYear = lowerBound.year == Date.now.year ? "" : " \(lowerBound.year)"
//        
//        let upper = "\(upperBound.day) \(upperBound.shortMonth)\(upperYear)"
//        
//        return if sameYear {
//            if sameMonth {
//                "\(lowerBound.day) – \(upper)"
//            } else {
//                "\(lowerBound.day) \(lowerBound.shortMonth) – \(upper)"
//            }
//        } else {
//            "\(lowerBound.day) \(lowerBound.shortMonth)\(lowerYear) – \(upper)"
//        }
//    }
//}
