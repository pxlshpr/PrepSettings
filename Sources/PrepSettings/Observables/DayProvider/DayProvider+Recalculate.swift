import Foundation
import PrepShared

extension DayProvider {
    static func recalculateAllDays() async throws {
        let daysStartDate = await fetchBackendDaysStartDate()
        let logStartDate = await fetchBackendLogStartDate()
        let startDate = daysStartDate ?? logStartDate

        var start = CFAbsoluteTimeGetCurrent()
        print("recalculateAllDays() started")
        let days = await fetchAllDaysFromBackend(
            from: startDate,
            createIfNotExisting: false
        )
        print("     fetchAllDaysFromDocuments took: \(CFAbsoluteTimeGetCurrent()-start)s")
        start = CFAbsoluteTimeGetCurrent()
        try await DayProvider.recalculateAllDays(days)
        print("     recalculateAllDays took: \(CFAbsoluteTimeGetCurrent()-start)s")
    }

    static func recalculateAllDays(
        _ days: [Date : Day],
        initialDays: [Date : Day]? = nil,
        syncStart: CFAbsoluteTime? = nil,
        cancellable: Bool = true
    ) async throws {
        
        print("🤖 recalculateAllDays started")

        let start = CFAbsoluteTimeGetCurrent()
        let initialDays = initialDays ?? days

        var latestHealthDetails: [HealthDetail: DatedHealthData] = [:]
        
//        let settings = await fetchSettingsFromDocuments()
//        let settingsProvider = SettingsProvider(settings: settings)
        let settingsProvider = SettingsProvider.shared
        let settings = settingsProvider.settings

        if cancellable {
            try Task.checkCancellation()
        }
        
        for date in days.keys.sorted() {
            
            guard
                let value = days[date],
                let initialDay = initialDays[date]
            else {
                fatalError() /// Remove in production
            }
            
            var day = value

            guard let healthDetails = day.healthDetails else {
                fatalError() /// Remove in production
            }
            
            /// Create a HealthProvider for it (which in turn fetches the latest health details)
            let healthProvider = HealthProvider(
                healthDetails: healthDetails,
                settingsProvider: settingsProvider
            )
            
            await healthProvider.recalculate(
                latestHealthDetails: latestHealthDetails,
                settings: settings,
                days: days
            )

            latestHealthDetails.extractLatestHealthDetails(from: healthDetails)
            
            day.healthDetails = healthProvider.healthDetails

            if cancellable {
                try Task.checkCancellation()
            }

            if initialDay.healthDetails != day.healthDetails {
                /// [ ] TBD: Reassign Daily Values after restructuring so that we store them in each `Day` as opposed to having a static list in Settings
                /// [ ] TBD: Recalculate any plans on this day too
            }

            if day != initialDay {
                await saveDayInBackend(day)
            }
        }
        print("✅ recalculateAllDays done in: \(CFAbsoluteTimeGetCurrent()-start)s")
        if let syncStart {
            print("✅ syncWithHealthKitAndRecalculateAllDays done in: \(CFAbsoluteTimeGetCurrent()-syncStart)s")
        }
    }
}
