import SwiftUI
import PrepShared

@Observable public class Provider {

    public var displayedDay: Day
    public var today: Day
    var previousToday: Day

    var saveTask: Task<Void, Error>? = nil

    public init(
        displayedDay: Day,
        today: Day,
        saveTask: Task<Void, Error>? = nil
    ) {
        self.displayedDay = displayedDay
        self.today = today
        self.previousToday = today
        self.saveTask = saveTask
    }
}

extension Provider {
    var displayedDate: Date {
        displayedDay.date
    }
}
