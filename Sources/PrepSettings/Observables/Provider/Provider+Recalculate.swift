import SwiftUI
import HealthKit
import PrepShared

extension Provider {
    func recalculate(
        latestHealthDetails: [HealthDetail: DatedHealthData],
        settings: Settings,
        days: [Date : Day]
    ) async {
        
        healthDetails.unsetPregnancyAndSmokingStatusIfNeeded()
        
        /// Do this before we calculate anything so that we have the latest available
        healthDetails.setLatestHealthDetails(latestHealthDetails)

        /// Recalculate LBM, fat percentage based on equations – before converting to their counterparts (otherwise we're calculating on possibly invalid values)
        await recalculateLeanBodyMasses()
        await recalculateFatPercentages()

        /// Convert LBM and fat percentage to their counterparts – before setting latest health details
        healthDetails.convertLeanBodyMassesToFatPercentages()
        healthDetails.convertFatPercentagesToLeanBodyMasses()

        /// Now recalculate Daily Values (do this after any lean body mass / fat percentage modifications have been done)
        healthDetails.recalculateDailyMeasurements(using: settings)

        await recalculateMaintenance(days)
    }
}

extension Provider {

    func recalculateLeanBodyMasses() async {
        let initial = healthDetails.leanBodyMass
        for (index, measurement) in initial.measurements.enumerated() {
            guard measurement.source == .equation,
                  let equation = measurement.equation
            else { continue }
            
            /// If we're unable to calculate the lean body mass for this measurement any more—remove it
            guard let kg = await calculateLeanBodyMassInKg(using: equation) else {
                healthDetails.leanBodyMass.measurements.remove(at: index)
                return
            }
            
            /// Otherwise re-set the existing value with the calculated one in case it changed
            healthDetails.leanBodyMass.measurements[index].leanBodyMassInKg = kg
        }
        
        /// Only continue if changes were actually made
        guard healthDetails.leanBodyMass != initial else { return }

        /// Re-set the daily value based on the new measurements
        let type = settings.dailyMeasurementType(for: .leanBodyMass)
        healthDetails.leanBodyMass.setDailyMeasurement(for: type)
    }
    
    func recalculateFatPercentages() async {
        let initial = healthDetails.fatPercentage
        for (index, measurement) in initial.measurements.enumerated() {
            guard measurement.source == .equation,
                  let equation = measurement.equation
            else { continue }
            
            /// If we're unable to calculate the fat percentage for this measurement any more—remove it
            guard let percent = await calculateFatPercentageInPercent(using: equation) else {
                healthDetails.fatPercentage.measurements.remove(at: index)
                return
            }
            
            /// Otherwise re-set the existing value with the calculated one in case it changed
            healthDetails.fatPercentage.measurements[index].percent = percent
        }
        
        /// Only continue if changes were actually made
        guard healthDetails.fatPercentage != initial else { return }

        /// Re-set the daily value based on the new measurements
        let type = settings.dailyMeasurementType(for: .fatPercentage)
        healthDetails.fatPercentage.setDailyMeasurement(for: type)
    }

    func recalculateMaintenance(_ days: [Date : Day]) async {
        await recalculateEstimatedMaintenanace()
        await recalculateAdaptiveMaintenance(days)
        healthDetails.maintenance.setKcal()
    }
    func recalculateAdaptiveMaintenance(_ days: [Date : Day]) async {
        await recalculateDietaryEnergy(days)
        await recalculateWeightChange(days)
        healthDetails.maintenance.adaptive.setKcal()
    }

    func recalculateWeightChange(_ days: [Date : Day]) async {
        let weightChange = healthDetails.maintenance.adaptive.weightChange
        guard weightChange.type == .weights else {
            healthDetails.maintenance.adaptive.weightChange.points = nil
            return
        }
        
        var points = weightChange.points ?? .init(date: healthDetails.date, interval: healthDetails.maintenance.adaptive.interval)
        
        func calculatePoint(_ point: inout WeightChangePoint) async {
            
            func movingAverageWeight(over interval: HealthInterval) -> Double? {
                var weights: [Date : HealthDetails.Weight] = [:]
                for index in 0..<interval.numberOfDays {
                    let date = point.date.startOfDay.moveDayBy(-index)
//                    let weight = await Provider.fetchOrCreateBackendWeight(for: date)
                    let weight = days[date]?.healthDetails.weight ?? .init()
                    weights[date] = weight
                }
                
                return weights.values
                    .compactMap { $0.weightInKg }
                    .average
            }
            
            point.kg = if let interval = point.movingAverageInterval {
                movingAverageWeight(over: interval)
            } else {
                (days[point.date]?.healthDetails.weight ?? .init())
                    .weightInKg
            }
        }
        
        await calculatePoint(&points.start)
        await calculatePoint(&points.end)
        
        let kg: Double? = if let end = points.end.kg, let start = points.start.kg {
            end - start
        } else {
            nil
        }
        
        healthDetails.maintenance.adaptive.weightChange.kg = kg
    }
    
    func recalculateDietaryEnergy(_ days: [Date : Day]) async {
        
        let interval = healthDetails.maintenance.adaptive.interval
        let date = healthDetails.date.startOfDay

        var points: [DietaryEnergyPoint] = []
        for index in 0..<interval.numberOfDays {
            let date = date.moveDayBy(-(index + 1))
            
            /// Fetch the point if it exists
            if let point = days[date]?.dietaryEnergyPoint {
                points.append(point)
            } else {
                let point = DietaryEnergyPoint(date: date, source: .notCounted)
                points.append(point)
            }
        }
        healthDetails.maintenance.adaptive.dietaryEnergy.kcalPerDay = HealthDetails.Maintenance.Adaptive.DietaryEnergy.calculateKcalPerDay(for: points)
    }
    
    func recalculateEstimatedMaintenanace() async {
        await recalculateRestingEnergy()
        await recalculateActiveEnergy()
        
        healthDetails.maintenance.estimate.setKcal()
    }
    
    func recalculateRestingEnergy() async {
        let restingEnergy = healthDetails.maintenance.estimate.restingEnergy
        guard
            restingEnergy.source == .equation,
            let equation = restingEnergy.equation
        else { return }
        let kcal = await calculateRestingEnergyInKcal(using: equation)
        healthDetails.maintenance.estimate.restingEnergy.kcal = kcal
    }
    
    func recalculateActiveEnergy() async {
        let activeEnergy = healthDetails.maintenance.estimate.activeEnergy
        guard
            let restingEnergyInKcal = healthDetails.maintenance.estimate.restingEnergy.kcal,
            activeEnergy.source == .activityLevel,
            let activityLevel = activeEnergy.activityLevel
        else { return }
        
        let kcal = activityLevel.calculate(for: restingEnergyInKcal)
        healthDetails.maintenance.estimate.activeEnergy.kcal = kcal
    }
}

extension Provider {
    func calculateRestingEnergyInKcal(
        using equation: RestingEnergyEquation
    ) async -> Double? {
        await equation.calculate(
            ageInYears: ageInYears,
            biologicalSex: biologicalSex,
            weightInKg: healthDetails.currentOrLatestWeightInKg,
            leanBodyMassInKg: healthDetails.currentOrLatestLeanBodyMassInKg,
            fatPercentage: healthDetails.currentOrLatestFatPercentage,
            heightInCm: healthDetails.currentOrLatestHeightInCm,
            preferLeanBodyMass: healthDetails.maintenance.estimate.restingEnergy.preferLeanBodyMass,
            energyUnit: .kcal
        )
    }
    
    func calculateFatPercentageInPercent(
        using equation: LeanBodyMassAndFatPercentageEquation
    ) async -> Double? {
        await equation.calculateFatPercentageInPercent(
            biologicalSex: biologicalSex,
            weightInKg: healthDetails.currentOrLatestWeightInKg,
            heightInCm: healthDetails.currentOrLatestHeightInCm,
            ageInYears: ageInYears
        )
    }
    
    func calculateLeanBodyMassInKg(
        using equation: LeanBodyMassAndFatPercentageEquation
    ) async -> Double? {
        await equation.calculateLeanBodyMassInKg(
            biologicalSex: biologicalSex,
            weightInKg: healthDetails.currentOrLatestWeightInKg,
            heightInCm: healthDetails.currentOrLatestHeightInCm,
            ageInYears: ageInYears
        )
    }
}


import Foundation
import PrepShared

extension Provider {
    
    static func recalculateAllDays() async throws {
        let daysStartDate = await fetchBackendDaysStartDate()
        let logStartDate = await fetchBackendLogStartDate()
        let startDate = daysStartDate ?? logStartDate

        var start = CFAbsoluteTimeGetCurrent()
        print("recalculateAllDays() started")
        let days = await fetchAllDaysFromBackend(
            from: startDate,
            createIfNotExisting: false
        )
        print("     fetchAllDaysFromDocuments took: \(CFAbsoluteTimeGetCurrent()-start)s")
        start = CFAbsoluteTimeGetCurrent()
        try await Provider.recalculateAllDays(days)
        print("     recalculateAllDays took: \(CFAbsoluteTimeGetCurrent()-start)s")
    }

    static func recalculateAllDays(
        _ days: [Date : Day],
        initialDays: [Date : Day]? = nil,
        syncStart: CFAbsoluteTime? = nil,
        cancellable: Bool = true
    ) async throws {
        
        print("🤖 recalculateAllDays started")

        let start = CFAbsoluteTimeGetCurrent()
        let initialDays = initialDays ?? days

        var latestHealthDetails: [HealthDetail: DatedHealthData] = [:]
        
        let provider = Provider.shared
        let settings = provider.settings

        if cancellable {
            try Task.checkCancellation()
        }
        
        for date in days.keys.sorted() {
            
            guard
                let value = days[date],
                let initialDay = initialDays[date]
            else {
                fatalError() /// Remove in production
            }
            
            var day = value

            let healthDetails = day.healthDetails
            
            let provider = Provider()
            provider.healthDetails = healthDetails

            await provider.recalculate(
                latestHealthDetails: latestHealthDetails,
                settings: settings,
                days: days
            )

            latestHealthDetails.extractLatestHealthDetails(from: healthDetails)
            
            day.healthDetails = provider.healthDetails

            if cancellable {
                try Task.checkCancellation()
            }

            if initialDay.healthDetails != day.healthDetails {
                /// [ ] TBD: Reassign Daily Values after restructuring so that we store them in each `Day` as opposed to having a static list in Settings
                /// [ ] TBD: Recalculate any plans on this day too
            }

            if day != initialDay {
                await saveDayInBackend(day)
            }
        }
        print("✅ recalculateAllDays done in: \(CFAbsoluteTimeGetCurrent()-start)s")
        if let syncStart {
            print("✅ syncWithHealthKitAndRecalculateAllDays done in: \(CFAbsoluteTimeGetCurrent()-syncStart)s")
        }
    }
}
