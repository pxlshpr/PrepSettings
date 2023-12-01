import Foundation

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
        let index = -date.numberOfDaysFrom(health.date)
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
        
        let maintenance = Health.MaintenanceEnergy(
            interval: health.maintenanceEnergy?.interval ?? DefaultMaintenanceEnergyInterval,
            weightChange: weightChange,
            dietaryEnergy: health.maintenanceEnergy?.dietaryEnergy ?? .init()
        )

        health.maintenanceEnergy = maintenance
    }
}

extension MaintenanceValues {
    
    var sortedDates: [Date] {
        values.keys.sorted()
    }
    
    var datesWithoutWeights: [Date]? {
        var dates: [Date] = []
        for date in sortedDates {
            guard values[date]?.weightInKg == nil else { continue }
            dates.append(date)
        }
        return dates.isEmpty ? nil : dates
    }
    
    var datesWithoutDietaryEnergy: [Date]? {
        var dates: [Date] = []
        for date in sortedDates {
            guard values[date]?.dietaryEnergyInKcal == nil else { continue }
            dates.append(date)
        }
        return dates.isEmpty ? nil : dates
    }
}

public extension HealthModel {
    var hasAdaptiveMaintenanceEnergyValue: Bool {
        maintenanceEnergyIsAdaptive
        && health.maintenanceEnergy?.adaptiveValue != nil
        && health.maintenanceEnergy?.error == nil
    }
}

extension HealthModel {
    func remove(_ type: HealthType) {
        health.remove(type)
    }
    
    func add(_ type: HealthType) {
        health.add(type)
    }
}

import SwiftUI

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
    
    /// Used when turning on adaptive calculation initially. Fetches backend and HealthKit data and calculates using those
    func calculateAdaptiveMaintenance() async throws {
        
        /// Get the backend values for the date range spanning the st
        let dateRange = health.dateRangeForMaintenanceBackendValues
        var values = try await delegate.maintenanceBackendValues(for: dateRange)
        
        if !isPreview {
            //TODO: Do these in parallel
            try await values.fillInMissingWeights(healthModel: self)
            try await values.fillInMissingDietaryEnergy()
        } else {
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

extension MaintenanceValues {
    mutating func fillInMissingWeights(healthModel: HealthModel) async throws {

        /// Get the range of days that are missing weight data and query them from HealthKit
        guard let datesWithoutWeights else { return }

        let healthKitValues = try await HealthKitQuantityRequest.weight
            .quantities(for: datesWithoutWeights)
            .valuesGroupedByDate
        
        for (date, quantities) in healthKitValues {
            guard
                let averageValue = quantities.averageValue,
                let lastQuantity = quantities.sortedByDate.last
            else { continue }
            
            /// Set the fetched value
            setWeightInKg(averageValue, for: date)
            
            //TODO: Consider sending this to another parallel task so we don't have to wait for it (first test how long this takes in practice)
            try await healthModel.delegate.updateBackendWeight(
                for: date,
                with: lastQuantity,
                source: .healthKit
            )
        }
    }
    
    mutating func fillInMissingDietaryEnergy() async throws {
        
        guard let dates = datesWithoutDietaryEnergy else { return }
        
        let healthKitValues = try await HealthStore
            .dailyDietaryEnergyTotalsInKcal(for: dates)
        
        for (date, value) in  healthKitValues {
            setDietaryEnergyInKcal(value, for: date, type: .healthKit)
        }
    }
}
