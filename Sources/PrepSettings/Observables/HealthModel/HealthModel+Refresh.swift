import SwiftUI
import PrepShared

public extension HealthModel {

    func refresh() async throws {
        
        let initialHealth = self.health
        
        guard isCurrent else { return }

        /// Set the model to ignore changes so that it doesn't redudantly fetch health twice (in `handleChanges`)
        ignoreChanges = true

        /// Modify health for the new day if needed
        health.modifyForNewDayIfNeeded()
        
        /// Fetch latest HealthKit data
        try await fetchHealthKitData()

        /// Recalculate HealthDetails in case new HealthKit data was fetched
        await MainActor.run {
            health.recalculate()
        }

        try await refreshAdaptiveMaintenance()
        
        /// Now turn off this flag so that manual user changes are handled appropriately
        ignoreChanges = false

        /// Finally save the changes
        try await saveHealth()
        
        /// If changes were made, set the updatedAt timestamp and tell the delegate that HealthDetails were changes, so that it may update plans etc
        if self.health != initialHealth {
            health.updatedAt = Date.now
        }
    }
}

public extension HealthModel {
    func refreshAdaptiveMaintenance() async throws {
        
        //TODO: Find out why using parallel tasks causes the adaptive struct to lose some data
        /// Fetch latest Dietary Energy and Weight Samples in parallel tasks
//        try await withThrowingTaskGroup(of: Void.self) { taskGroup in
//            taskGroup.addTask {
                try await self.refreshDietaryEnergyValues()
//            }
//            taskGroup.addTask {
                try await self.refreshWeightSamples()
//            }
//            while let _ = try await taskGroup.next() { }
//        }

        /// Recalculate adaptive maintenance
        health.maintenance?.adaptive.recalculateAdaptiveMaintenance()
    }
    
    func refreshDietaryEnergyValues() async throws {
        guard let samples = health.maintenance?.adaptive.dietaryEnergy.samples
        else {
            return
        }
        
        try await withThrowingTaskGroup(of: Void.self) { taskGroup in
            /// For each day in interval
            for (index, sample) in samples.enumerated() {
                taskGroup.addTask {
                    let date = self.health.date.moveDayBy(-index)
                    let value: Double? = switch sample.type {
                    case .userEntered, .average:
                        /// Leave user entered samples and averaged values (which are essentially blank) as they are
                        sample.value
                    case .logged:
                        /// Query the delegate for the value
                        try await self.delegate.dietaryEnergyInKcal(on: date)
                    case .healthKit:
                        /// Query HealthStore for the HealthKit value
                        try await HealthStore.dietaryEnergyTotalInKcal(for: date)
                    }
                    self.health.maintenance?.adaptive.dietaryEnergy.samples[index].value = value
                }
            }
            while let _ = try await taskGroup.next() { }
        }
    }
    
    func refreshWeightSamples() async throws {
        guard let weightChange = health.maintenance?.adaptive.weightChange,
              weightChange.type == .usingWeights,
              let adaptiveInterval = health.maintenance?.adaptive.interval
        else {
            return
        }
        
        try await withThrowingTaskGroup(of: Void.self) { taskGroup in

            try await self.health.maintenance?.adaptive.weightChange.current
                .refresh(for: self.health.date)

            try await self.health.maintenance?.adaptive.weightChange.previous
                .refresh(for: adaptiveInterval.startDate(with: self.health.date))

            while let _ = try await taskGroup.next() { }
        }
    }
}

public extension HealthDetails {
    mutating func modifyForNewDayIfNeeded() {
        /// Only continue if needed, if the date doesn't match today
        guard date.startOfDay != Date.now.startOfDay else {
            return
        }

        modifyAdaptiveMaintenanceForNewDay()

        /// Set the date to the new day (today)
        self.date = Date.now.startOfDay
    }
    
    mutating func modifyAdaptiveMaintenanceForNewDay() {
        
        guard let interval = maintenance?.adaptive.interval else { return }
        
        maintenance?.adaptive.weightChange.modifyForNewDay(
            from: date,
            maintenanceInterval: interval
        )
        
        maintenance?.adaptive.dietaryEnergy.modifyForNewDay(
            from: date,
            maintenanceInterval: interval
        )
    }
}
