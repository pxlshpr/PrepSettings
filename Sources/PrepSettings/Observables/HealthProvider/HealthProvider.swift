import SwiftUI
import HealthKit

@Observable public class HealthProvider {
    
    public var settingsProvider: SettingsProvider
    public let isCurrent: Bool
    public var healthDetails: HealthDetails

    var unsavedHealthDetails: HealthDetails
    var saveTask: Task<Void, Error>? = nil
    
    public init(
        healthDetails: HealthDetails,
        settingsProvider: SettingsProvider
    ) {
        self.settingsProvider = settingsProvider
        self.isCurrent = healthDetails.date.isToday
        self.unsavedHealthDetails = healthDetails
        self.healthDetails = healthDetails
    }
}

#Preview("Demo") {
    DemoView()
}
