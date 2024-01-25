import Foundation

public extension Provider {
    var displayedDate: Date {
        get {
            _displayedDate
        }
        set {
            _displayedDate = newValue
            fetchDisplayedDay()
        }
    }
}
