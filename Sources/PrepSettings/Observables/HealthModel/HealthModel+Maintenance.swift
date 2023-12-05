import SwiftUI

extension HealthModel {
    /// Used when turning on adaptive calculation initially. Fetches backend and HealthKit data and calculates using those
    func calculateAdaptiveMaintenance() async throws {
        
        /// Get the backend values for the date range spanning the st
        let dateRange = health.dateRangeForMaintenanceBackendValues
        var values = try await delegate.maintenanceBackendValues(for: dateRange)
        
        if !isPreview {
            //TODO: Do these in parallel
            try await values.fillInMissingWeightsFromHealthKit(healthModel: self)
            try await values.fillInMissingDietaryEnergyFromHealthKit()
        } else {
            /// Don't touch HealthKit if we've in a preview
        }
        
        let maintenance = Health.MaintenanceEnergy(
            interval: health.maintenanceEnergy?.interval ?? DefaultMaintenanceEnergyInterval,
            weightChange: weightChange(from: values),
            dietaryEnergy: dietaryEnergy(from: values)
        )

        await MainActor.run {
            withAnimation {
                health.maintenanceEnergy = maintenance
            }
        }
    }
}

extension HealthModel {
    
    func weightChange(from values: MaintenanceValues) -> WeightChange {
        let maintenance = health.maintenanceEnergy ?? .init()
        var weightChange = maintenance.weightChange
        weightChange.setValues(values, health.date, maintenance.interval)
        return weightChange
    }
    
    func dietaryEnergy(from values: MaintenanceValues) -> DietaryEnergy {
        let maintenance = health.maintenanceEnergy ?? .init()
        var dietaryEnergy = maintenance.dietaryEnergy
        dietaryEnergy.setValues(values, health.date, maintenance.interval)
        dietaryEnergy.fillEmptyValuesWithAverages()
        return dietaryEnergy
    }
}

extension HealthModel {
    
    func setDietaryEnergySample(_ sample: DietaryEnergySample, for date: Date) {
        var dietaryEnergy = health.maintenanceEnergy?.dietaryEnergy ?? .init()
        let index = DietaryEnergy.indexForDate(date, from: health.date)
        dietaryEnergy.samples[index] = sample
        dietaryEnergy.fillEmptyValuesWithAverages()
        
        let maintenance = Health.MaintenanceEnergy(
            interval: health.maintenanceEnergy?.interval ?? DefaultMaintenanceEnergyInterval,
            weightChange: health.maintenanceEnergy?.weightChange ?? .init(),
            dietaryEnergy: dietaryEnergy
        )

        health.maintenanceEnergy = maintenance
    }
    
    func setWeightSample(_ sample: WeightSample, isPrevious: Bool) {
        var weightChange = health.maintenanceEnergy?.weightChange ?? .init()
        if isPrevious {
            weightChange.previous = sample
        } else {
            weightChange.current = sample
        }
        weightChange.calculateDelta()
        
        let maintenance = Health.MaintenanceEnergy(
            interval: health.maintenanceEnergy?.interval ?? DefaultMaintenanceEnergyInterval,
            weightChange: weightChange,
            dietaryEnergy: health.maintenanceEnergy?.dietaryEnergy ?? .init()
        )

        health.maintenanceEnergy = maintenance
    }
}

extension HealthModel {

    /// Returns any backend weight values we have for the date range (specified by `interval`) used for the moving average for `date`
    func weightValuesForMovingAverage(
        interval: HealthInterval, date: Date
    ) async throws -> [Int: Double] {

        let startDate = interval.startDate(with: date)
        let range = startDate...date
        let values = try await delegate.maintenanceBackendValues(for: range)

        var weightValues: [Int: Double] = [:]
        for i in 0..<interval.numberOfDays {
            let date = date.moveDayBy(-i).startOfDay
            if let weightInKg = values.values[date]?.weightInKg {
                weightValues[i] = weightInKg
            }
        }
        return weightValues
    }
}
