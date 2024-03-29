import Foundation
import HealthKit
import PrepShared

extension Provider {
    
    func save(shouldResync: Bool = false) {
        let healthDetailsDidChange = healthDetails != unsavedHealthDetails
        
        /// Safeguard against any redundant calls to save to avoid cancelling the ongoing task and redundantly interacting with the backend
        guard healthDetailsDidChange || shouldResync else {
            print("🙅🏽‍♂️ Cancelling redundant save()")
            return
        }

        print("💾 Saving Provider for: \(healthDetails.date.shortDateString)")

        daySaveTask?.cancel()
        daySaveTask = Task {
            /// Set this before we call `refetchHealthDetails()` which would override the `unsavedHealthDetails` making the changes undetectable
            let resync = shouldResync || healthDetails.containsChangesInSyncableMeasurements(from: unsavedHealthDetails)
            
            try await saveHealthDetailsInBackend(healthDetails)
            try Task.checkCancellation()

            /// Do this first to ensure that recalculations happen instantly (since in most cases, the sync is simply to provide the Health App with new measurements)
            try await Provider.recalculateAllDays()

            /// Refetch HealthDetails as recalculations may have modified it further
            await refetchHealthDetails()

            try Task.checkCancellation()
            
            if resync  {
                print("🔄 resync is true so Syncing")
                /// If any syncable measurements were changed, trigger a sync (and subsequent recalculate)
                try await Self.syncWithHealthKitAndRecalculateAllDays()

                /// Refetch HealthDetails as the sync and recalculate may have modified it further
                await refetchHealthDetails()
            } else {
                print("🥖 resync is false so not syncing")
            }
        }
    }
    
    func refetchHealthDetails() async {
        let healthDetails = await fetchOrCreateHealthDetailsFromBackend(healthDetails.date)
        self.healthDetails = healthDetails

        /// Also save it as the `unsavedHealthDetails` so that we can check if a resync is needed with the next save
        self.unsavedHealthDetails = healthDetails
    }
}

extension Provider {
    
    func saveMaintenance(_ maintenance: HealthDetails.Maintenance, shouldResync: Bool) {
        healthDetails.maintenance = maintenance
        save(shouldResync: shouldResync)
    }
    
    func saveRestingEnergy(_ restingEnergy: HealthDetails.Maintenance.Estimate.RestingEnergy) {
        healthDetails.maintenance.estimate.restingEnergy = restingEnergy
        save()
    }
    
    func saveEstimate(_ estimate: HealthDetails.Maintenance.Estimate) {
        healthDetails.maintenance.estimate = estimate
        save()
    }
    
    func saveActiveEnergy(_ activeEnergy: HealthDetails.Maintenance.Estimate.ActiveEnergy) {
        healthDetails.maintenance.estimate.activeEnergy = activeEnergy
        save()
    }
    
    func savePregnancyStatus(_ pregnancyStatus: PregnancyStatus) {
        healthDetails.pregnancyStatus = pregnancyStatus
        save()
    }
    
    func saveBiologicalSex(_ sex: BiologicalSex) {
        healthDetails.biologicalSex = sex
        save()
    }
    
    func saveDateOfBirth(_ date: Date?) {
        healthDetails.dateOfBirth = date
        save()
    }
    
    func saveSmokingStatus(_ smokingStatus: SmokingStatus) {
        healthDetails.smokingStatus = smokingStatus
        save()
    }
    
    //TODO: Sync stuff
    /// [ ] Handle sync being turned on and off for these here
    func saveHeight(_ height: HealthDetails.Height) {
        healthDetails.height = height
        save()
    }
    
    func saveWeight(_ weight: HealthDetails.Weight) {
        healthDetails.weight = weight
        save()
    }
    
    func saveLeanBodyMass(_ leanBodyMass: HealthDetails.LeanBodyMass) {
        healthDetails.leanBodyMass = leanBodyMass
        save()
    }
    
    func saveFatPercentage(_ fatPercentage: HealthDetails.FatPercentage) {
        healthDetails.fatPercentage = fatPercentage
        save()
    }
    
    //TODO: Replace Mock coding with actual persistence

    /// These trigger syncs if a modification was made
    func updateLatestWeight(_ weight: HealthDetails.Weight) {
        guard let date = healthDetails.replacementsForMissing.datedWeight?.date else { return }
        healthDetails.replacementsForMissing.datedWeight?.weight = weight
        
        Task {
            let shouldResync = try await saveWeight(weight, for: date)
            save(shouldResync: shouldResync)
        }
    }
    
    func updateLatestHeight(_ height: HealthDetails.Height) {
        guard let date = healthDetails.replacementsForMissing.datedHeight?.date else { return }
        healthDetails.replacementsForMissing.datedHeight?.height = height

        Task {
            let shouldResync = try await saveHeight(height, for: date)
            save(shouldResync: shouldResync)
        }
    }
    
    func updateLatestFatPercentage(_ fatPercentage: HealthDetails.FatPercentage) {
        guard let date = healthDetails.replacementsForMissing.datedFatPercentage?.date else { return }
        healthDetails.replacementsForMissing.datedFatPercentage?.fatPercentage = fatPercentage
        Task {
            let shouldResync = try await saveFatPercentage(fatPercentage, for: date)
            save(shouldResync: shouldResync)
        }
    }
    
    func updateLatestLeanBodyMass(_ leanBodyMass: HealthDetails.LeanBodyMass) {
        guard let date = healthDetails.replacementsForMissing.datedLeanBodyMass?.date else { return }
        healthDetails.replacementsForMissing.datedLeanBodyMass?.leanBodyMass = leanBodyMass
        Task {
            let shouldResync = try await saveLeanBodyMass(leanBodyMass, for: date)
            save(shouldResync: shouldResync)
        }
    }

    /// These do not trigger syncs if a modification was made
    func updateLatestMaintenance(_ maintenance: HealthDetails.Maintenance, shouldResync: Bool = false) {
        guard let date = healthDetails.replacementsForMissing.datedMaintenance?.date else { return }
        healthDetails.replacementsForMissing.datedMaintenance?.maintenance = maintenance
        Task {
            try await saveMaintenance(maintenance, for: date)
            save(shouldResync: shouldResync)
        }
    }

    
    func updateLatestPregnancyStatus(_ pregnancyStatus: PregnancyStatus) {
        guard let date = healthDetails.replacementsForMissing.datedPregnancyStatus?.date else { return }
        healthDetails.replacementsForMissing.datedPregnancyStatus?.pregnancyStatus = pregnancyStatus
        Task {
            try await savePregnancyStatus(pregnancyStatus, for: date)
            save()
        }
    }
    
    //MARK: - Save for other days
    
    /// The following would trigger a sync if any modifications were made, so their return values indicate whether a modification was made so that we don't redundantly cause a sync
    func saveWeight(_ weight: HealthDetails.Weight, for date: Date) async throws -> Bool {
        var healthDetails = await fetchOrCreateHealthDetailsFromBackend(date)
        guard healthDetails.weight != weight else {
            return false
        }
        healthDetails.weight = weight
        try await saveHealthDetailsInBackend(healthDetails)
        return true
    }
    
    func saveHeight(_ height: HealthDetails.Height, for date: Date) async throws -> Bool {
        var healthDetails = await fetchOrCreateHealthDetailsFromBackend(date)
        guard healthDetails.height != height else {
            return false
        }
        healthDetails.height = height
        try await saveHealthDetailsInBackend(healthDetails)
        return true
    }
    
    func saveFatPercentage(_ fatPercentage: HealthDetails.FatPercentage, for date: Date) async throws -> Bool {
        var healthDetails = await fetchOrCreateHealthDetailsFromBackend(date)
        guard healthDetails.fatPercentage != fatPercentage else {
            return false
        }
        healthDetails.fatPercentage = fatPercentage
        try await saveHealthDetailsInBackend(healthDetails)
        return true
    }
    
    func saveLeanBodyMass(_ leanBodyMass: HealthDetails.LeanBodyMass, for date: Date) async throws -> Bool {
        var healthDetails = await fetchOrCreateHealthDetailsFromBackend(date)
        guard healthDetails.leanBodyMass != leanBodyMass else {
            return false
        }
        healthDetails.leanBodyMass = leanBodyMass
        try await saveHealthDetailsInBackend(healthDetails)
        return true
    }
    
    /// We're not interested if the following result in modifications, as we wouldn't be triggering a sync even if they did (as we don't submit them to HealthKit)
    func saveMaintenance(_ maintenance: HealthDetails.Maintenance, for date: Date) async throws {
        var healthDetails = await fetchOrCreateHealthDetailsFromBackend(date)
        healthDetails.maintenance = maintenance
        try await saveHealthDetailsInBackend(healthDetails)
    }
    
    func savePregnancyStatus(_ pregnancyStatus: PregnancyStatus, for date: Date) async throws {
        var healthDetails = await fetchOrCreateHealthDetailsFromBackend(date)
        healthDetails.pregnancyStatus = pregnancyStatus
        try await saveHealthDetailsInBackend(healthDetails)
    }
}

extension Provider {
    func setDailyMeasurementType(for healthDetail: HealthDetail, to type: DailyMeasurementType) {
        settings.setDailyMeasurementType(type, for: healthDetail)
        saveSettings()
        /// Calling this to only recalculate as no changes were made to save. But we want to make sure there is only one of this occurring at any given time.
        save()
    }
    
    func setHealthKitSyncing(for healthDetail: HealthDetail, to isOn: Bool) {
        settings.setHealthKitSyncing(for: healthDetail, to: isOn)
        saveSettings()
        if isOn {
            Task {
                try await Provider.syncWithHealthKitAndRecalculateAllDays()
            }
        }
    }
}

extension Provider {
    static func saveHealthKitSample(
        _ sample: HKQuantitySample,
        for type: HealthKitType
    ) async throws {

        //TODO: Provider
        /// [ ] Shouldn't this just use these settings since its a singleton? (unless we're using it for another date when resyncing, but even then wouldn't that just grab the same Settings from the backend?)
        let settings = Provider.shared.settings
        guard let dailyMeasurementType = settings.dailyMeasurementType(forHealthKitType: type) else {
            return
        }
        var healthDetails = await fetchOrCreateHealthDetailsFromBackend(sample.date.startOfDay)
        switch type {
        case .weight:
            healthDetails.weight.addHealthKitSample(sample, using: dailyMeasurementType)
        case .leanBodyMass:
            healthDetails.leanBodyMass.addHealthKitSample(sample, using: dailyMeasurementType)
        case .height:
            healthDetails.height.addHealthKitSample(sample, using: dailyMeasurementType)
        case .fatPercentage:
            healthDetails.fatPercentage.addHealthKitSample(sample, using: dailyMeasurementType)
        default:
            break
        }
        try await saveHealthDetailsInBackend(healthDetails)
    }
}
