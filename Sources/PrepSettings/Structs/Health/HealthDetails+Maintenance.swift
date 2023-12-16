import Foundation
import PrepShared

public let DefaultMaintenanceEnergyInterval: HealthInterval = .init(1, .week)
public let DefaultWeightMovingAverageInterval: HealthInterval = .init(1, .week)
public let DefaultMovingAverageWeights: [HealthDetails.Weight] = Array(
    repeating: .init(source: .healthKit, isDailyAverage: true),
    count: DefaultWeightMovingAverageInterval.numberOfDays
)

extension HealthDetails {
//    var dateRangeForMaintenanceBackendValues: ClosedRange<Date> {
//        let interval = maintenance?.adaptive.interval ?? DefaultMaintenanceEnergyInterval
//        let previousWeightMovingAverageInterval = maintenance?.adaptive.weightChange.previous.movingAverageInterval ?? DefaultWeightMovingAverageInterval
//        
//        let intervalStartDate = interval.startDate(with: date)
//        let movingAverageStartDate = previousWeightMovingAverageInterval.startDate(with: intervalStartDate)
//        return movingAverageStartDate...date
//    }

    var dateRangeForMaintenanceCalculation: ClosedRange<Date> {
        let interval = maintenance?.adaptive.interval ?? DefaultMaintenanceEnergyInterval
        let intervalStartDate = interval.startDate(with: date)
        return intervalStartDate...date
    }

}

//extension Health {
//    
//    func calculate() async throws -> Health.MaintenanceEnergy? {
//        
//        guard let maintenanceEnergy else { return nil }
//        
//        /// Fill in the `WeightChange` data by fetching from HealthKit or backend
//        let weightChange = try await fillWeightChange(maintenanceEnergy.weightChange)
//        
//        /// Fill in the `DietaryEnergy` data by fetching from HealthKit or backend
//        let dietaryEnergy = try await fillDietaryEnergy(maintenanceEnergy.dietaryEnergy)
//        
//        /// Now create the Maintenance energy with the filled in `WeightChange` and `DietaryEnergy` which attempts to calculate it and sets a value or an error accordingly
//        return Health.MaintenanceEnergy(
//            interval: maintenanceEnergy.interval,
//            weightChange: weightChange,
//            dietaryEnergy: dietaryEnergy
//        )
//    }
//    
//    public func fillWeightChange(_ weightChange: WeightChange) async throws -> WeightChange {
//        
//        let interval = maintenanceEnergy?.interval ?? DefaultMaintenanceEnergyInterval
//        
//        var weightChange = weightChange
//        
//        func request(for date: Date) -> HealthKitQuantityRequest {
////            HealthKitQuantityRequest(.weight, bodyMassUnit.healthKitUnit, date)
//            HealthKitQuantityRequest(.weight, BodyMassUnit.kg.healthKitUnit)
//        }
//        
//        switch weightChange.current.type {
//        case .healthKit:
//            try await weightChange.current.fill(using: request(for: date))
//        default:
//            break
//        }
//        
//        switch weightChange.previous.type {
//        case .healthKit:
//            let previousDate = interval.startDate(with: date)
//            try await weightChange.previous.fill(using: request(for: previousDate))
//        default:
//            break
//        }
//        
//        return weightChange
//    }
//    
//    public func fillDietaryEnergy(_ dietaryEnergy: DietaryEnergy) async throws -> DietaryEnergy {
//        
//        var dietaryEnergy = dietaryEnergy
//        
//        /// If we have any `HealthKit` sourced dietary energy values in the samples, this will be indicated by a range of dates provided
//        if let dateRange = dietaryEnergy.healthKitDatesRange(for: date) {
//            /// If we do, grab the values that coincide with these dates
//            let values = try await HealthStore.dailyDietaryEnergyValues(
//                dateRange: dateRange,
////                energyUnit: energyUnit
//                energyUnit: .kcal
//            )
//            for i in values.keys {
//                guard i < dietaryEnergy.samples.count else { continue }
//                dietaryEnergy.samples[i].value = values[i]
//            }
//        }
//        
//        /// Now grab any backend sourced dietary energy values
//
//        /// Once this is done, fill in the empty values with the averages
//        dietaryEnergy.fillEmptyValuesWithAverages()
//
//        return dietaryEnergy
//    }
//}

//extension Health.MaintenanceEnergy {
//    static func calculate(
//        weightChange: WeightChange,
//        dietaryEnergy: DietaryEnergy,
//        interval: HealthInterval
//    ) -> Result<Double, MaintenanceCalculationError> {
//        
//        guard let weightDeltaInKcal = weightChange.deltaEnergyEquivalentInKcal,
//              let dietaryEnergyTotal = dietaryEnergy.total //TODO: Handle kcal/kj
//        else {
//            return switch (weightChange.isEmpty, dietaryEnergy.isEmpty) {
//            case (true, false): .failure(.noWeightData)
//            case (false, true): .failure(.noNutritionData)
//            default:            .failure(.noWeightOrNutritionData)
//            }
//        }
//        
//        let value = (dietaryEnergyTotal - weightDeltaInKcal) / Double(interval.numberOfDays)
//        
//        return .success(value)
//    }
//}

extension HealthDetails.Maintenance.Adaptive {
    static func calculate(
        weightChange: WeightChange,
        dietaryEnergy: DietaryEnergy,
        interval: HealthInterval
    ) -> Result<Double, MaintenanceCalculationError> {
        
        guard let weightDeltaInKcal = weightChange.deltaEnergyEquivalentInKcal,
              let dietaryEnergyTotal = dietaryEnergy.total //TODO: Handle kcal/kj
        else {
            return switch (weightChange.isEmpty, dietaryEnergy.isEmpty) {
            case (true, false): .failure(.noWeightData)
            case (false, true): .failure(.noNutritionData)
            default:            .failure(.noWeightOrNutritionData)
            }
        }
        
        let value = (dietaryEnergyTotal - weightDeltaInKcal) / Double(interval.numberOfDays)
        
        guard value > 0 else {
            return .failure(.weightChangeExceedsNutrition)
        }
        
        return .success(max(value, 0))
    }
}

public extension HealthDetails {
    /// Estimate of maintenance energy calculated by adding estimated active and resting energies
    var estimatedMaintenanceInKcal: Double? {
        guard let activeEnergyValue, let restingEnergyValue else {
            return nil
        }
        return activeEnergyValue + restingEnergyValue
    }
    
    func estimatedMaintenance(in unit: EnergyUnit) -> Double? {
        guard let estimatedMaintenanceInKcal else { return nil }
        return EnergyUnit.kcal.convert(estimatedMaintenanceInKcal, to: unit)
    }
}
