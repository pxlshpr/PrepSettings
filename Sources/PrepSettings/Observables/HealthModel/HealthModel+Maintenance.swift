import SwiftUI

extension HealthModel {
    
    func calculateAdaptiveMaintenance() {
        withAnimation {
            health.maintenance?.adaptive.recalculate()
        }
    }
    
    /// Used when turning on adaptive calculation initially. Fetches backend and HealthKit data and calculates using those
    func fetchBackendValuesForAdaptiveMaintenance() async throws {
        
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
        
        let adaptive = Health.Maintenance.Adaptive(
            interval: health.maintenance?.adaptive.interval ?? DefaultMaintenanceEnergyInterval,
            weightChange: weightChange(from: values),
            dietaryEnergy: dietaryEnergy(from: values)
        )

        await MainActor.run {
            withAnimation {
                health.maintenance?.adaptive = adaptive
            }
        }
    }
}

extension HealthModel {
    
    func weightChange(from values: MaintenanceValues) -> WeightChange {
        let maintenance = health.maintenance ?? .init()
        var weightChange = maintenance.adaptive.weightChange
        weightChange.setValues(values, health.date, maintenance.adaptive.interval)
        weightChange.calculateDelta()
        return weightChange
    }
    
    func dietaryEnergy(from values: MaintenanceValues) -> DietaryEnergy {
        let maintenance = health.maintenance ?? .init()
        var dietaryEnergy = maintenance.adaptive.dietaryEnergy
        dietaryEnergy.setValues(values, health.date, maintenance.adaptive.interval)
        dietaryEnergy.fillEmptyValuesWithAverages()
        return dietaryEnergy
    }
}

extension HealthModel {
    
    func setDietaryEnergySample(_ sample: DietaryEnergySample, for date: Date) {
        var dietaryEnergy = health.maintenance?.adaptive.dietaryEnergy ?? .init()
        let index = DietaryEnergy.indexForDate(date, from: health.date)
        dietaryEnergy.samples[index] = sample
        dietaryEnergy.fillEmptyValuesWithAverages()
        
        let adaptive = Health.Maintenance.Adaptive(
            interval: health.maintenance?.adaptive.interval ?? DefaultMaintenanceEnergyInterval,
            weightChange: health.maintenance?.adaptive.weightChange ?? .init(),
            dietaryEnergy: dietaryEnergy
        )

        health.maintenance?.adaptive = adaptive
    }
    
    func setWeightSample(_ sample: WeightSample, isPrevious: Bool) {
        var weightChange = health.maintenance?.adaptive.weightChange ?? .init()
        if isPrevious {
            weightChange.previous = sample
        } else {
            weightChange.current = sample
        }
        weightChange.calculateDelta()
        
        let adaptive = Health.Maintenance.Adaptive(
            interval: health.maintenance?.adaptive.interval ?? DefaultMaintenanceEnergyInterval,
            weightChange: weightChange,
            dietaryEnergy: health.maintenance?.adaptive.dietaryEnergy ?? .init()
        )

        withAnimation {
            health.maintenance?.adaptive = adaptive
        }
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
