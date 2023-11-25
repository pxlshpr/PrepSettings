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
    func setWeightSample(_ sample: MaintenanceWeightSample, isPrevious: Bool) {
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

extension HealthModel {

    /// Used when turning on adaptive calculation initially. Fetches backend and HealthKit data and calculates using those
    func turnOnAdaptiveMaintenance() async throws {
        
        /// Get the backend values for the date range spanning the st
        let dateRange = health.dateRangeForMaintenanceBackendValues
        var values = try await delegate.maintenanceBackendValues(for: dateRange)
        
        /// Get the range of days that are missing weight data and query them from HealthKit
        if let dates = values.datesWithoutWeights {
            
            let healthKitValues = try await HealthKitQuantityRequest.weight
                .quantities(for: dates)
                .valuesGroupedByDate
            
            for (date, quantities) in healthKitValues {
                guard
                    let averageValue = quantities.averageValue,
                    let lastQuantity = quantities.sortedByDate.last
                else { continue }
                
                /// Set the fetched value
                values.setWeightInKg(averageValue, for: date)
                
                //TODO: Consider sending this to another parallel task so we don't have to wait for it (first test how long this takes in practice)
                try await delegate.updateBackendWeight(
                    for: date,
                    with: lastQuantity,
                    source: .healthKit
                )
            }
        }
        
        /// [ ] Now get the range of days that are missing dietary energy data and query them from HealthKit
        if let dates = values.datesWithoutDietaryEnergy {
            let healthKitValues = try await HealthStore
                .dailyDietaryEnergyTotalsInKcal(for: dates)
            
            for (date, value) in  healthKitValues {
                values.setDietaryEnergyInKcal(value, for: date, type: .healthKit)
            }
        }
        
        let maintenance = Health.MaintenanceEnergy(
            interval: health.maintenanceEnergy?.interval ?? DefaultMaintenanceEnergyInterval,
            weightChange: weightChange(from: values),
            dietaryEnergy: dietaryEnergy(from: values)
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
