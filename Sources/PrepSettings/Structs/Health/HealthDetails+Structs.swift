import Foundation
import HealthKit
import PrepShared

public extension HealthDetails {
    
    //MARK: New
    struct Maintenance: Hashable, Codable {
        public var adaptive: Adaptive
        public var estimated: Estimated
        public var prefersAdaptive: Bool
        
        public struct Adaptive: Hashable, Codable {
            public var interval: HealthInterval
            public var weightChange: WeightChange
            public var dietaryEnergy: DietaryEnergy
            public var value: Double?
            public var error: MaintenanceCalculationError?
            
            public init() {
                self.interval = DefaultMaintenanceEnergyInterval
                self.weightChange = .init()
                self.dietaryEnergy = .init()
                self.value = nil
                self.error = nil
            }
            
            public init(
                interval: HealthInterval,
                weightChange: WeightChange,
                dietaryEnergy: DietaryEnergy
            ) {
                self.interval = interval
                self.weightChange = weightChange
                self.dietaryEnergy = dietaryEnergy
                
                let result = Self.calculate(
                    weightChange: weightChange,
                    dietaryEnergy: dietaryEnergy,
                    interval: interval
                )
                switch result {
                case .success(let value):
                    self.value = value
                    self.error = nil
                case .failure(let error):
                    self.value = nil
                    self.error = error
                }
            }
            
            mutating func recalculate() {
                let result = Self.calculate(
                    weightChange: weightChange,
                    dietaryEnergy: dietaryEnergy,
                    interval: interval
                )
                switch result {
                case .success(let value):
                    self.value = value
                    self.error = nil
                case .failure(let error):
                    self.value = nil
                    self.error = error
                }
            }
        }
        
        public struct Estimated: Hashable, Codable {
            public var restingEnergy: RestingEnergy
            public var activeEnergy: ActiveEnergy
            public var value: Double?
            
            public init() {
                self.restingEnergy = .init(source: .default)
                self.activeEnergy = .init(source: .default)
                self.value = nil
            }
        }
        
        public var value: Double? {
            guard prefersAdaptive else { return estimated.value }
            return adaptive.value ?? estimated.value
        }
        
        public init(prefersAdaptive: Bool = true) {
            self.adaptive = Adaptive()
            self.estimated = Estimated()
            self.prefersAdaptive = prefersAdaptive
        }
    }
    
    //MARK: Legacy
//    struct MaintenanceEnergy: Hashable, Codable {
//        
//        public var isAdaptive: Bool
//        public var adaptiveValue: Double?
//        public var error: MaintenanceCalculationError?
//        
//        public var interval: HealthInterval
//        public var weightChange: WeightChange
//        public var dietaryEnergy: DietaryEnergy
//
//        public init(isAdaptive: Bool = true) {
//            self.isAdaptive = isAdaptive
//            self.adaptiveValue = nil
//            self.error = nil
//            self.interval = DefaultMaintenanceEnergyInterval
//            self.weightChange = .init()
//            self.dietaryEnergy = .init()
//        }
//        
//        public init(
//            interval: HealthInterval,
//            weightChange: WeightChange,
//            dietaryEnergy: DietaryEnergy
//        ) {
//            self.isAdaptive = true
//            self.interval = interval
//            self.weightChange = weightChange
//            self.dietaryEnergy = dietaryEnergy
//            
//            let result = Self.calculate(
//                weightChange: weightChange,
//                dietaryEnergy: dietaryEnergy,
//                interval: interval
//            )
//            switch result {
//            case .success(let value):
//                self.adaptiveValue = value
//                self.error = nil
//            case .failure(let error):
//                self.adaptiveValue = nil
//                self.error = error
//            }
//        }
//    }
    
    struct RestingEnergy: Hashable, Codable {
        public var source: RestingEnergySource
        public var equation: RestingEnergyEquation?
        public var interval: HealthInterval?
        public var value: Double?
        
        public init(
            source: RestingEnergySource,
            equation: RestingEnergyEquation? = nil,
            interval: HealthInterval? = nil,
            value: Double? = nil
        ) {
            self.source = source
            switch source {
            case .healthKit:
                self.equation = nil
                self.interval = interval ?? .default
            case .equation:
                self.equation = equation ?? .default
                self.interval = nil
            case .userEntered:
                self.equation = nil
                self.interval = nil
            }
            self.value = value
        }
    }
    
    struct ActiveEnergy: Hashable, Codable {
        public var source: ActiveEnergySource
        public var activityLevel: ActivityLevel?
        public var interval: HealthInterval?
        public var value: Double?
        
        public init(
            source: ActiveEnergySource,
            activityLevel: ActivityLevel? = nil,
            interval: HealthInterval? = nil,
            value: Double? = nil
        ) {
            self.source = source
            
            switch source {
            case .healthKit:
                self.activityLevel = nil
                self.interval = interval ?? .default
            case .activityLevel:
                self.activityLevel = activityLevel ?? .default
                self.interval = nil
            case .userEntered:
                self.activityLevel = nil
                self.interval = nil
            }
            
            self.value = value
        }
    }
    
    struct Age: Hashable, Codable {
        public var source: AgeSource
        public var dateOfBirthComponents: DateComponents?
        public var value: Int?
        
        public init(
            source: AgeSource,
            dateOfBirthComponents: DateComponents? = nil,
            value: Int? = nil
        ) {
            self.source = source
            self.dateOfBirthComponents = dateOfBirthComponents
            self.value = value
        }
        
        public var dateOfBirth: Date? {
            get {
                guard let dateOfBirthComponents else { return nil }
                var components = dateOfBirthComponents
                components.hour = 0
                components.minute = 0
                components.second = 0
                return Calendar.current.date(from: components)
            }
            set {
                guard let newValue else {
                    dateOfBirthComponents = nil
                    return
                }
                dateOfBirthComponents = newValue.dateComponentsWithoutTime
            }
        }
    }

    struct BiologicalSex: Hashable, Codable {
        public var source: HealthSource
        public var value: Sex?
    }

    struct Weight: Hashable, Codable {
        public var source: HealthSource
        public var isDailyAverage: Bool
        public var healthKitQuantities: [Quantity]?
        public var valueInKg: Double?

        public init(
            source: HealthSource,
            isDailyAverage: Bool = false,
            healthKitQuantities: [Quantity]? = nil,
            valueInKg: Double? = nil
        ) {
            self.source = source
            self.isDailyAverage = isDailyAverage
            self.healthKitQuantities = healthKitQuantities
            self.valueInKg = valueInKg
        }
        
        public func value(in unit: BodyMassUnit) -> Double? {
            guard let valueInKg else { return nil }
            return BodyMassUnit.kg.convert(valueInKg, to: unit)
        }
    }

    struct LeanBodyMass: Hashable, Codable {
        public var source: LeanBodyMassSource
        public var equation: LeanBodyMassEquation?
        public var quantity: Quantity?
        
        public init(
            source: LeanBodyMassSource,
            equation: LeanBodyMassEquation? = nil,
            quantity: Quantity? = nil
        ) {
            self.source = source
            switch source {
            case .healthKit:
                self.equation = nil
            case .equation:
                self.equation = equation ?? .default
            case .fatPercentage:
                self.equation = nil
            case .userEntered:
                self.equation = nil
            }
            self.quantity = quantity
        }
    }
}
