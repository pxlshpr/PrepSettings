import Foundation
import PrepShared

//TODO: Replace these with actual backend manipulation in Prep

extension HealthProvider {
    
    static func fetchOrCreateBackendWeight(for date: Date) async -> HealthDetails.Weight {
        let healthDetails = await fetchOrCreateHealthDetailsFromBackend(date)
        return healthDetails.weight
    }
}

extension HealthProvider {

    //TODO: These two are duplicates, so consolidate them
    func saveDietaryEnergyPoint(_ point: DietaryEnergyPoint) {
        //TODO: Get any other HealthDetails (other than the one in this HealthProvider) that uses this point and get them to update within an instantiated HealthProvider as well
        Task {
            var day = await DayProvider.fetchOrCreateDayFromBackend(point.date)
            day.dietaryEnergyPoint = point
            await DayProvider.saveDayInBackend(day)
        }
    }
    
    static func setBackendDietaryEnergyPoint(_ point: DietaryEnergyPoint, for date: Date) {
        Task {
            var day = await DayProvider.fetchOrCreateDayFromBackend(date)
            day.dietaryEnergyPoint = point
            await DayProvider.saveDayInBackend(day)
        }
    }

    static func fetchBackendDietaryEnergyPoint(for date: Date) async -> DietaryEnergyPoint? {
        let day = await DayProvider.fetchOrCreateDayFromBackend(date)
        return day.dietaryEnergyPoint
    }
}

extension HealthProvider {
    
    static func saveHealthDetailsInBackend(_ healthDetails: HealthDetails) async throws {
        //TODO: Do this
    }
    
    func saveHealthDetailsInBackend(_ healthDetails: HealthDetails) async  throws {
        try await Self.saveHealthDetailsInBackend(healthDetails)
    }
}

extension HealthProvider {
    static func fetchOrCreateHealthDetailsFromBackend(_ date: Date) async -> HealthDetails {
        .init(date: date)
    }
    func fetchOrCreateHealthDetailsFromBackend(_ date: Date) async -> HealthDetails {
        await Self.fetchOrCreateHealthDetailsFromBackend(date)
    }
}
