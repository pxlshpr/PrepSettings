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
        
        /// Fetch latest Dietary Energy and Weight Samples in parallel tasks
        try await withThrowingTaskGroup(of: Void.self) { taskGroup in
            taskGroup.addTask {
                try await self.refreshDietaryEnergyValues()
            }
            taskGroup.addTask {
                try await self.refreshWeightSamples()
            }
            while let _ = try await taskGroup.next() { }
        }

        /// [ ] Re-calculate weight delta if needed

        /// [ ] Fill in empty dietary energy days with average values if needed

        /// [ ] Recalculate adaptive maintenance
    }
    
    func refreshDietaryEnergyValues() async throws {
        guard let samples = health.maintenance?.adaptive.dietaryEnergy.samples
        else {
            return
        }
        
        try await withThrowingTaskGroup(of: Void.self) { taskGroup in
            /// For each day in interval
            for sample in samples {
                taskGroup.addTask {
                    switch sample.type {
                    case .userEntered, .average:
                        /// Leave user entered samples and averaged values (which are essentially blank) as they are
                        break
                    case .logged:
                        /// [ ] Query the delegate for the value
                        break
                    case .healthKit:
                        /// [ ] Query HealthStore for the HealthKit value
                        break
                    }
                }
            }
            while let _ = try await taskGroup.next() { }
        }
    }
    
    func refreshWeightSamples() async throws {
        guard let weightChange = health.maintenance?.adaptive.weightChange,
              weightChange.type == .usingWeights
        else {
            return
        }
        
        try await withThrowingTaskGroup(of: Void.self) { taskGroup in
            
            switch weightChange.current.source {
            case .userEntered:
                /// Leave user entered weights intact
                break
            case .healthKit:
                /// [ ] Query HealthStore for the HealthKit value
                break
            case .movingAverage:
                /// [ ] For each day in the interval, either query the backend for the value (including hte type), OR use the stored type to either get the HealthKit or backend value if needed
                break
            }

            switch weightChange.previous.source {
            case .userEntered:
                /// Leave user entered weights intact
                break
            case .healthKit:
                /// [ ] Query HealthStore for the HealthKit value
                break
            case .movingAverage:
                /// [ ] For each day in the interval, either query the backend for the value (including hte type), OR use the stored type to either get the HealthKit or backend value if needed
                break
            }
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

        func modifyDietaryEnergy() {
            
            /// Determine how much to shift the array by getting the number of days since `date` (up to a maximum of the number of days in the interval)
            guard let intervalDays = maintenance?.adaptive.interval.numberOfDays else { return }
            let shiftCount = min(intervalDays, Date.now.numberOfDaysFrom(date))

            /// Insert that many new samples at start of array with source set as `.logged`
            let newSamples = Array(
                repeating: DietaryEnergySample(type: .logged),
                count: shiftCount
            )
            maintenance?.adaptive.dietaryEnergy.samples.insert(contentsOf: newSamples, at: 0)
            
            /// Remove that many samples from the end of the array to maintain the number of days of the interval
            maintenance?.adaptive.dietaryEnergy.samples.removeLast(shiftCount)
        }
        
        guard let interval = maintenance?.adaptive.interval else { return }
        maintenance?.adaptive.weightChange.modifyForNewDay(
            from: date,
            maintenanceInterval: interval
        )
//        modifyWeightChange()
        modifyDietaryEnergy()
    }
}
