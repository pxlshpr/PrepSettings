import Foundation

extension Int {
    var dateOfBirthComponentsForAge: DateComponents {
        Calendar.current.dateComponents(
            [.year, .month, .day],
            from: Date.now.moveYearBy(-self)
        )
    }
}
