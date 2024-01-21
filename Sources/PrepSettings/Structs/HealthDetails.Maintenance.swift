import Foundation
import PrepShared

extension HealthDetails {
    public struct Maintenance: Hashable, Codable {
        
        public var type: MaintenanceType = .estimated
        public var kcal: Double?
        public var adaptive = Adaptive()
        public var estimate = Estimate()
        public var useEstimateAsFallback: Bool = true
        public var hasConfigured: Bool = false
        
        public struct Adaptive: Hashable, Codable {
            public var kcal: Double?
            public var interval: HealthInterval
            public var dietaryEnergy = DietaryEnergy()
            public var weightChange = WeightChange()
            
            public init(
                kcal: Double? = nil,
                interval: HealthInterval = .init(1, .week),
                dietaryEnergyPoints points: [DietaryEnergyPoint] = [],
                weightChange: WeightChange = WeightChange()
            ) {
                self.kcal = kcal
                self.interval = interval
                self.dietaryEnergy = .init(points: points)
                self.weightChange = weightChange

                self.kcal = self.calculateIfValid()
            }

            public struct DietaryEnergy: Hashable, Codable {
                public var kcalPerDay: Double?

                init(kcalPerDay: Double? = nil) {
                    self.kcalPerDay = kcalPerDay
                }
                
                init(points: [DietaryEnergyPoint]) {
                    var points = points
                    points.fillAverages()
                    self.kcalPerDay = points.kcalPerDay
                }
                
                static func calculateKcalPerDay(for points: [DietaryEnergyPoint]) -> Double? {
                    var points = points
                    points.fillAverages()
                    return points.kcalPerDay
                }
            }
        }
        
        public struct Estimate: Hashable, Codable {
            public var kcal: Double?
            public var restingEnergy = RestingEnergy()
            public var activeEnergy = ActiveEnergy()
            
            public struct RestingEnergy: Hashable, Codable {
                public var kcal: Double? = nil
                public var source: RestingEnergySource = .equation
                public var equation: RestingEnergyEquation? = .katchMcardle
                public var preferLeanBodyMass: Bool = true
                public var healthKitFetchSettings: HealthKitFetchSettings?
            }
            
            public struct ActiveEnergy: Hashable, Codable {
                public var kcal: Double? = nil
                public var source: ActiveEnergySource = .activityLevel
                public var activityLevel: ActivityLevel? = .lightlyActive
                public var healthKitFetchSettings: HealthKitFetchSettings?
            }
            
        }
    }
}

extension HealthDetails.Maintenance.Estimate.RestingEnergy: HealthKitEnergy {
    var isHealthKitSourced: Bool { source == .healthKit }
    var energyType: EnergyType { .resting }
}

extension HealthDetails.Maintenance.Estimate.ActiveEnergy: HealthKitEnergy {
    var isHealthKitSourced: Bool { source == .healthKit }
    var energyType: EnergyType { .active }
}


extension HealthDetails.Maintenance.Adaptive {
//    static func calculate(
//        weightChange: WeightChange,
//        dietaryEnergy: DietaryEnergy,
//        interval: HealthInterval
//    ) -> Result<Double, MaintenanceCalculationError> {
//        
//        guard let weightDeltaInKcal = weightChange.energyEquivalentInKcal,
//              let dietaryEnergyTotal = dietaryEnergy.totalInKcal
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
//        guard value > 0 else {
//            return .failure(.weightChangeExceedsNutrition)
//        }
//        
//        return .success(max(value, 0))
//    }
    
//    static func calculate(
//        weightChange: WeightChange,
//        dietaryEnergyPoints: [DietaryEnergyPoint],
//        interval: HealthInterval
//    ) -> Result<Double, MaintenanceCalculationError> {
//        
//        guard let weightDeltaInKcal = weightChange.energyEquivalentInKcal,
//              let dietaryEnergyTotal = dietaryEnergyPoints.totalInKcal
//        else {
//            return switch (weightChange.isEmpty, dietaryEnergyPoints.isEmpty) {
//            case (true, false): .failure(.noWeightData)
//            case (false, true): .failure(.noNutritionData)
//            default:            .failure(.noWeightOrNutritionData)
//            }
//        }
//        
//        let value = (dietaryEnergyTotal - weightDeltaInKcal) / Double(interval.numberOfDays)
//        
//        guard value > 0 else {
//            return .failure(.weightChangeExceedsNutrition)
//        }
//        
//        return .success(max(value, 0))
//    }

    static func calculate(
        interval: HealthInterval,
        weightChange: WeightChange,
        dietaryEnergy: DietaryEnergy
    ) -> Double? {
        guard let weightDeltaInKcal = weightChange.energyEquivalentInKcal,
              let kcalPerDay = dietaryEnergy.kcalPerDay else {
            return nil
        }
        let totalKcal = kcalPerDay * Double(interval.numberOfDays)
        return (totalKcal - weightDeltaInKcal) / Double(interval.numberOfDays)
    }
    
    func calculateIfValid() -> Double? {
        guard let kcal = Self.calculate(
            interval: interval,
            weightChange: weightChange,
            dietaryEnergy: dietaryEnergy
        ) else { return nil }

        guard kcal >= MinimumAdaptiveEnergyInKcal else { return nil }
        return kcal
    }
    
    static func minimumEnergyString(in energyUnit: EnergyUnit) -> String {
        let converted = EnergyUnit.kcal.convert(MinimumAdaptiveEnergyInKcal, to: energyUnit)
        return "\(converted.formattedEnergy) \(energyUnit.abbreviation)"
    }
}

extension HealthDetails.Maintenance {
    func valueString(in unit: EnergyUnit) -> String {
        kcal.valueString(convertedFrom: .kcal, to: unit)
    }
}

extension HealthDetails.Maintenance.Adaptive {
    mutating func setKcal() {
        kcal = calculateIfValid()
    }
}
extension HealthDetails.Maintenance.Estimate {
    mutating func setKcal() {
        kcal = if let resting = restingEnergy.kcal, let active = activeEnergy.kcal {
            resting + active
        } else {
            nil
        }
    }
}

extension HealthDetails.Maintenance {
    mutating func setKcal() {
        kcal = switch type {
        case .adaptive:
            if let adaptive = adaptive.kcal {
                adaptive
            } else {
                if useEstimateAsFallback {
                    estimate.kcal
                } else {
                    nil
                }
            }
        case .estimated:
            estimate.kcal
        }
    }
}
