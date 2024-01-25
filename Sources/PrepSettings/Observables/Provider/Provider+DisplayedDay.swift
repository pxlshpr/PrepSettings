import Foundation

public extension Provider {
    var displayedDate: Date {
        get {
            _displayedDate
        }
        set {
            _displayedDate = newValue
            
            displayedDayChangeTask?.cancel()
            displayedDayChangeTask = Task {
                guard let fetchOrCreate = handlers?.day.fetchOrCreate else {
                    fatalError()
                }
                let day = try await fetchOrCreate(newValue)
                try Task.checkCancellation()
                await MainActor.run {
                    self.displayedDay = day
                }
            }
        }
    }
}
