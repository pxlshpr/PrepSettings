import Foundation
import HealthKit
import PrepShared

public extension Health {
    
    //MARK: Interval Types
    
    var restingEnergyIntervalType: HealthIntervalType {
        get { restingEnergy?.interval?.intervalType ?? .default }
        set {
            restingEnergy?.interval?.intervalType = newValue
            switch newValue {
            case .average:
                cleanupRestingEnergyIntervalValue()
            case .previousDay:
                restingEnergy?.interval = .init(1, .day)
            case .sameDay:
                restingEnergy?.interval = .init(0, .day)
            }
        }
    }
    
    var activeEnergyIntervalType: HealthIntervalType {
        get { activeEnergy?.interval?.intervalType ?? .default }
        set {
            activeEnergy?.interval?.intervalType = newValue
            switch newValue {
            case .average:
                cleanupActiveEnergyIntervalValue()
            case .previousDay:
                activeEnergy?.interval = .init(1, .day)
            case .sameDay:
                activeEnergy?.interval = .init(0, .day)
            }
        }
    }
    
    //MARK: Interval Periods
    
    var restingEnergyIntervalPeriod: HealthPeriod {
        get { restingEnergy?.interval?.period ?? .default }
        set {
            restingEnergy?.interval?.period = newValue
            cleanupRestingEnergyIntervalValue()
        }
    }
    
    var activeEnergyIntervalPeriod: HealthPeriod {
        get { activeEnergy?.interval?.period ?? .default }
        set {
            activeEnergy?.interval?.period = newValue
            cleanupActiveEnergyIntervalValue()
        }
    }
    
    //MARK: Interval Value
    
    var restingEnergyIntervalValue: Int {
        get { restingEnergy?.interval?.value ?? 1 }
        set {
            guard newValue >= restingEnergyIntervalPeriod.minValue,
                  newValue <= restingEnergyIntervalPeriod.maxValue
            else { return }
            restingEnergy?.interval?.value = newValue
        }
    }
    
    var activeEnergyIntervalValue: Int {
        get { activeEnergy?.interval?.value ?? 1 }
        set {
            guard newValue >= activeEnergyIntervalPeriod.minValue,
                  newValue <= activeEnergyIntervalPeriod.maxValue
            else { return }
            activeEnergy?.interval?.value = newValue
        }
    }
    
    //MARK: Interval cleanup
    
    mutating func cleanupRestingEnergyIntervalValue() {
        restingEnergy?.interval?.correctIfNeeded()
    }
    
    mutating func cleanupActiveEnergyIntervalValue() {
        activeEnergy?.interval?.correctIfNeeded()
    }
    
    //MARK: Sources
    
    var ageSource: AgeSource {
        get { age?.source ?? .default }
        set {
            age = Age(source: newValue)
            //            guard age != nil else {
            //                age = Age(source: newValue)
            //                return
            //            }
            //            age?.source = newValue
        }
    }
    
    var sexSource: HealthSource {
        get { sex?.source ?? .default }
        set {
            guard sex != nil else {
                sex = BiologicalSex(source: newValue)
                return
            }
            sex?.source = newValue
        }
    }
    
    var weightSource: HealthSource {
        get { weight?.source ?? .default }
        set {
            guard weight != nil else {
                weight = HealthQuantity(source: newValue)
                return
            }
            weight?.source = newValue
        }
    }
    
    var heightSource: HealthSource {
        get { height?.source ?? .default }
        set {
            guard height != nil else {
                height = HealthQuantity(source: newValue)
                return
            }
            height?.source = newValue
        }
    }
    
    var leanBodyMassSource: LeanBodyMassSource {
        get { leanBodyMass?.source ?? .default }
        set {
            guard leanBodyMass != nil else {
                leanBodyMass = LeanBodyMass(source: newValue)
                return
            }
            leanBodyMass?.source = newValue
            leanBodyMass?.equation = newValue == .equation ? .default : nil
        }
    }
    
    var restingEnergySource: RestingEnergySource {
        get { restingEnergy?.source ?? .default }
        set {
            guard restingEnergy != nil else {
                restingEnergy = RestingEnergy(source: newValue)
                return
            }
            restingEnergy?.source = newValue
            restingEnergy?.interval = newValue == .healthKit ? .default : nil
            restingEnergy?.equation = newValue == .equation ? .default : nil
        }
    }
    
    var activeEnergySource: ActiveEnergySource {
        get { activeEnergy?.source ?? .default }
        set {
            guard activeEnergy != nil else {
                activeEnergy = ActiveEnergy(source: newValue)
                return
            }
            activeEnergy?.source = newValue
            activeEnergy?.interval = newValue == .healthKit ? .default : nil
            activeEnergy?.activityLevel = newValue == .activityLevel ? .default : nil
        }
    }
    
    //MARK: Equations
    
    var restingEnergyEquation: RestingEnergyEquation {
        get { restingEnergy?.equation ?? .default }
        set {
            guard restingEnergy != nil else {
                restingEnergy = RestingEnergy(source: .equation, equation: newValue)
                return
            }
            restingEnergy?.equation = newValue
        }
    }
    
    var activeEnergyActivityLevel: ActivityLevel {
        get { activeEnergy?.activityLevel ?? .default }
        set {
            guard activeEnergy != nil else {
                activeEnergy = ActiveEnergy(source: .activityLevel, activityLevel: newValue)
                return
            }
            activeEnergy?.activityLevel = newValue
        }
    }
    
    var leanBodyMassEquation: LeanBodyMassEquation {
        get { leanBodyMass?.equation ?? .default }
        set {
            guard leanBodyMass != nil else {
                leanBodyMass = LeanBodyMass(source: .equation, equation: newValue)
                return
            }
            leanBodyMass?.equation = newValue
        }
    }
}

//MARK: Values

public extension Health {
    
    var activeEnergyValue: Double? {
        get { activeEnergy?.value }
        set {
            guard activeEnergy != nil else {
                activeEnergy = ActiveEnergy(
                    source: .userEntered,
                    value: newValue
                )
                return
            }
            activeEnergy?.value = newValue
        }
    }
    
    var restingEnergyValue: Double? {
        get { restingEnergy?.value }
        set {
            guard restingEnergy != nil else {
                restingEnergy = RestingEnergy(
                    source: .userEntered,
                    value: newValue
                )
                return
            }
            restingEnergy?.value = newValue
        }
    }
    
    var ageValue: Int? {
        get { age?.value }
        set {
            guard age != nil else {
                age = Age(source: .userEnteredAge, value: newValue)
                return
            }
            age?.value = newValue
        }
    }

    var ageDateOfBirth: Date? {
        get { age?.dateOfBirth }
        set {
            guard let newValue else {
                age?.dateOfBirth = nil
                return
            }
            let components = Calendar.current.dateComponents([.year, .month, .day], from: newValue)
            age = Age(
                source: .userEnteredDateOfBirth,
                dateOfBirthComponents: components,
                value: components.age
            )
        }
    }

    var sexValue: Sex? {
        get { sex?.value }
        set {
            guard sex != nil else {
                sex = BiologicalSex(source: .userEntered, value: newValue)
                return
            }
            sex?.value = newValue
        }
    }

    var weightQuantity: Quantity? {
        get { weight?.quantity }
        set {
            guard weight != nil else {
                weight = HealthQuantity(
                    source: .userEntered,
                    quantity: newValue
                )
                return
            }
            weight?.quantity = newValue
        }
    }
    
    var heightQuantity: Quantity? {
        get { height?.quantity }
        set {
            guard height != nil else {
                height = HealthQuantity(
                    source: .userEntered,
                    quantity: newValue
                )
                return
            }
            height?.quantity = newValue
        }
    }
    
    var leanBodyMassQuantity: Quantity? {
        get { leanBodyMass?.quantity }
        set {
            guard leanBodyMass != nil else {
                leanBodyMass = LeanBodyMass(
                    source: .userEntered,
                    quantity: newValue
                )
                return
            }
            leanBodyMass?.quantity = newValue
        }
    }
}
