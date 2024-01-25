import Foundation
import PrepShared

//TODO: Replace these with actual backend manipulation in Prep

extension Provider {
    
    static func fetchOrCreateBackendWeight(for date: Date) async -> HealthDetails.Weight {
        let healthDetails = await fetchOrCreateHealthDetailsFromBackend(date)
        return healthDetails.weight
    }
}

extension Provider {

    //TODO: These two are duplicates, so consolidate them
    func saveDietaryEnergyPoint(_ point: DietaryEnergyPoint) {
        //TODO: Get any other HealthDetails (other than the one in this Provider) that uses this point and get them to update within an instantiated Provider as well
        Task {
            var day = await Provider.fetchOrCreateDayFromBackend(point.date)
            day.dietaryEnergyPoint = point
            await Provider.saveDayInBackend(day)
        }
    }
    
    static func setBackendDietaryEnergyPoint(_ point: DietaryEnergyPoint, for date: Date) {
        Task {
            var day = await Provider.fetchOrCreateDayFromBackend(date)
            day.dietaryEnergyPoint = point
            await Provider.saveDayInBackend(day)
        }
    }

    static func fetchBackendDietaryEnergyPoint(for date: Date) async -> DietaryEnergyPoint? {
        let day = await Provider.fetchOrCreateDayFromBackend(date)
        return day.dietaryEnergyPoint
    }
}

extension Provider {
    
    static func saveHealthDetailsInBackend(_ healthDetails: HealthDetails) async throws {
        //TODO: Do this
    }
    
    func saveHealthDetailsInBackend(_ healthDetails: HealthDetails) async  throws {
        try await Self.saveHealthDetailsInBackend(healthDetails)
    }
}

extension Provider {
    static func fetchOrCreateHealthDetailsFromBackend(_ date: Date) async -> HealthDetails {
        .init(date: date)
    }
    func fetchOrCreateHealthDetailsFromBackend(_ date: Date) async -> HealthDetails {
        await Self.fetchOrCreateHealthDetailsFromBackend(date)
    }
}

//MARK: - Previously DayProvider+Backend

import Foundation
import PrepShared

let DaysStartDateKey = "DaysStartDate"

public extension Provider {
    //TODO: Make sure that the start date gets the first date that actually has food logged in it so that we don't get a Day we may have created to house something like a legacy height measurement.
    static func fetchBackendLogStartDate() async -> Date {
        Date.now
//        LogStartDate
    }
    
    static func fetchBackendDaysStartDate() async -> Date? {
        guard let string = UserDefaults.standard.string(forKey: DaysStartDateKey) else {
            return nil
        }
        return Date(fromDateString: string)
    }
    
    static func updateDaysStartDate(_ date: Date) async {
        UserDefaults.standard.setValue(date.dateString, forKey: DaysStartDateKey)
    }
    
    static func fetchBackendEnergyInKcal(for date: Date) async -> Double? {
        nil
//        let day = await fetchOrCreateDayFromDocuments(date)
//        return day.energyInKcal
    }
    
    static func fetchPrelogDeletedHealthKitUUIDs() async -> [UUID] {
        []
//        let days = await fetchAllPreLogDaysFromDocuments()
//        return days.map { $1.healthDetails.deletedHealthKitUUIDs }.flatMap { $0 }
    }
}

public extension Provider {
    static func saveDayInBackend(_ day: Day) async {
    }

    static func fetchAllDaysFromBackend(
        from startDate: Date,
        to endDate: Date = Date.now,
        createIfNotExisting: Bool
    ) async -> [Date : Day] {
        [:]
//        await fetchAllDaysFromDocuments(
//            from: startDate,
//            createIfNotExisting: false
//        )
    }
    
    static func fetchOrCreateDayFromBackend(_ date: Date) async -> Day {
        Day(dateString: date.dateString)
    }
    
    func fetchOrCreateDayFromBackend(_ date: Date) async -> Day {
        await Self.fetchOrCreateDayFromBackend(date)
    }
}

