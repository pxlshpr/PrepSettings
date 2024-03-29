//import Foundation
//import PrepShared
//
//public extension Date {
//    var calendarDayString: String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy_MM_dd"
//        return dateFormatter.string(from: self).lowercased()
//    }
//}
//
//public extension Date {
//    var healthShortFormat: String {
//        let dayString: String
//        var timeString = ""
//        if Calendar.current.isDateInToday(self) {
//            dayString = "Today"
//            timeString = shortTime
//        }
//        else if Calendar.current.isDateInYesterday(self) {
//            dayString = "Yesterday"
//        }
//        else if Calendar.current.isDateInTomorrow(self) {
//            dayString = "Tomorrow"
//        }
//        else {
//            let formatter = DateFormatter()
//            let sameYear = year == Date().year
//            formatter.dateFormat = sameYear ? "d MMM" : "d MMM yy"
//            dayString = formatter.string(from: self)
//        }
//        if timeString.isEmpty {
//            return dayString
//        } else {
//            return timeString
//        }
//    }
//
//    var healthDateFormat: String {
//        let formatter = DateFormatter()
//        let sameYear = year == Date().year
//        formatter.dateFormat = sameYear ? "d MMM" : "d MMM yyyy"
//        return formatter.string(from: self)
//    }
//    
//    var healthFormat: String {
//        
//        let timeString = healthTimeFormat
//        
//        let dateFormatter = DateFormatter()
//        let sameYear = year == Date().year
//        dateFormatter.dateFormat = sameYear ? "d MMM" : "d MMM yy"
//        let dayString = dateFormatter.string(from: self)
//
//        return dayString + ", " + timeString
//    }
//    
//    var healthTimeFormat: String {
//        let timeFormatter = DateFormatter()
//        timeFormatter.dateFormat = "h:mm a"
//        return timeFormatter.string(from: self).lowercased()
//    }
//    
//    var healthEnergyFormat: String {
//        let dayString: String
//        if Calendar.current.isDateInToday(self) { dayString = "Today" }
//        else if Calendar.current.isDateInYesterday(self) { dayString = "Yesterday" }
//        else if Calendar.current.isDateInTomorrow(self) { dayString = "Tomorrow" }
//        else {
//            let formatter = DateFormatter()
//            let sameYear = year == Date().year
//            formatter.dateFormat = sameYear ? "d MMM" : "d MMM yy"
//            dayString = formatter.string(from: self)
//        }
//        return dayString
//    }
//}
//
//public extension ClosedRange<Date> {
//    var description: String {
//        "\(lowerBound.calendarDayString) to \(upperBound.calendarDayString)"
//    }
//    
//    var days: [Date] {
//        var days: [Date] = []
//        let calendar = Calendar(identifier: .gregorian)
//        calendar.enumerateDates(
//            startingAfter: lowerBound,
//            matching: DateComponents(hour: 0, minute: 0, second:0),
//            matchingPolicy: .nextTime)
//        { (date, _, stop) in
//            guard let date = date, date <= upperBound else {
//                stop = true
//                return
//            }
//            days.append(date)
//        }
//        return days
//    }
//}
//
//public extension Date {
//    var dateComponentsWithoutTime: DateComponents {
//        Calendar.current.dateComponents(
//            [.year, .month, .day],
//            from: self
//        )
//    }
//}
//
//public extension Date {
//    var adaptiveMaintenanceDateString: String {
//        let formatter = DateFormatter()
//        if self.year == Date().year {
//            formatter.dateFormat = "d MMM"
//        } else {
//            formatter.dateFormat = "d MMM yyyy"
//        }
//        return formatter.string(from: self)
//    }
//}
