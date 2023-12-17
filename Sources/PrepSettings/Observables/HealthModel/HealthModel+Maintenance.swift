import SwiftUI

extension HealthModel {
    
    func calculateAdaptiveMaintenance() {
        withAnimation {
            health.maintenance?.adaptive.recalculateAdaptiveMaintenance()
        }
    }
}

extension HealthModel {
    
    func setDietaryEnergySample(_ sample: DietaryEnergySample, for date: Date) {
        var dietaryEnergy = health.maintenance?.adaptive.dietaryEnergy ?? .init()
        let index = DietaryEnergy.indexForDate(date, from: health.date)
        dietaryEnergy.samples[index] = sample
        dietaryEnergy.fillEmptyValuesWithAverages()
        
        let adaptive = HealthDetails.Maintenance.Adaptive(
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
        
        let adaptive = HealthDetails.Maintenance.Adaptive(
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
