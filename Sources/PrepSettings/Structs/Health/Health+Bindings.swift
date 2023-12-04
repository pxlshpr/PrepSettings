import Foundation
import HealthKit
import PrepShared

public extension Health {
    
    //MARK: Energy Burn
    var maintenanceEnergyIsAdaptive: Bool {
        get { maintenanceEnergy?.isAdaptive ?? false }
        set {
            guard maintenanceEnergy != nil else {
                maintenanceEnergy = .init(isAdaptive: newValue)
                return
            }
            maintenanceEnergy?.isAdaptive = newValue
            /// If we've turned it off, clear the previous value
            if !newValue {
                maintenanceEnergy?.adaptiveValue = nil
            }
        }
    }
    
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
            
            /// Either use the existing age or set the default age
            let value = age?.value ?? newValue.defaultValue
            
            let components = switch newValue {
            case .userEnteredDateOfBirth:   age?.dateOfBirthComponents
            default:                        value.dateOfBirthComponentsForAge
            }
            age = Age(source: newValue, dateOfBirthComponents: components, value: value)
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
            if newValue != .healthKit, sex?.value == .other {
                /// Reset this when changing from `HealthSource.healthKit` to `.userEntered` and we had `Sex.other` set
                sex?.value = .female
            }
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
            weight?.quantity?.date = nil
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
            height?.quantity?.date = nil
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

extension Health {
    mutating func handleFocusLoss(for type: HealthType) {
        
        let typesToRemoveIfNil: [HealthType] = [.weight, .height, .leanBodyMass, .age]
        for type in typesToRemoveIfNil {
            if valueIsNil(for: type) {
                remove(type)
            }
        }
        
        let typesToSetToZeroIfNil: [HealthType] = [.activeEnergy, .restingEnergy]
        for type in typesToSetToZeroIfNil {
            if valueIsNil(for: type) {
                guard let zeroValue = HealthKitValue.zeroValue(for: type) else { continue }
                setHealthKitValue(zeroValue, for: type)
            }
        }
        
//        switch type {
//        case .activeEnergy:     if activeEnergyValue == nil { activeEnergyValue = 0 }
//        case .restingEnergy:    if restingEnergyValue == nil { restingEnergyValue = 0 }
//        case .weight:           if weightValue == nil { remove(.weight) }
//        case .height:           if heightValue == nil { remove(.height) }
//        case .leanBodyMass:     if leanBodyMassValue == nil { remove(.leanBodyMass) }
//        case .age:              if ageValue == nil { remove(.age) }
//        case .fatPercentage:    if fatPercentage == nil { fatPercentage = 0 }
//        default:
//            break
//        }
    }
}

public extension Health {
    
//    var maintenanceEnergyAdaptiveValue: Double? {
//        get { maintenanceEnergy?.adaptiveValue }
//        set {
//            guard maintenanceEnergy != nil else {
//                maintenanceEnergy = MaintenanceEnergy(
//                    isAdaptive: true,
//                    adaptiveValue: newValue
//                )
//                return
//            }
//            maintenanceEnergy?.adaptiveValue = newValue
//        }
//    }
//    
//    var maintenanceEnergyAdaptiveError: AdaptiveMaintenanceError? {
//        get { maintenanceEnergy?.error }
//        set {
//            guard maintenanceEnergy != nil else {
//                maintenanceEnergy = MaintenanceEnergy(
//                    isAdaptive: true,
//                    adaptiveValue: nil,
//                    error: newValue
//                )
//                return
//            }
//            maintenanceEnergy?.error = newValue
//        }
//    }
    
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
    
    func restingEnergyValue(in unit: EnergyUnit) -> Double? {
        guard let restingEnergyValue else { return nil }
        return EnergyUnit.kcal.convert(restingEnergyValue, to: unit)
    }

    func activeEnergyValue(in unit: EnergyUnit) -> Double? {
        guard let activeEnergyValue else { return nil }
        return EnergyUnit.kcal.convert(activeEnergyValue, to: unit)
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

    var ageHealthKitDateComponents: DateComponents? {
        get { age?.dateOfBirthComponents }
        set {
            guard let newValue else {
                age?.dateOfBirthComponents = nil
                age?.value = nil
                return
            }
            age = Age(
                source: age?.source ?? .default,
                dateOfBirthComponents: newValue,
                value: newValue.age
            )
        }
    }
    
    /// Only to be used when user is entering date
    var ageUserEnteredDateOfBirth: Date? {
        get { age?.dateOfBirth }
        set {
            guard let newValue else {
                age?.dateOfBirth = nil
                return
            }
            let components = newValue.dateComponentsWithoutTime
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
