import Foundation

public extension Health {

    mutating func initializeHealthKitValues() {
        weight = .init(source: .healthKit)
        height = .init(source: .healthKit)
        sex = .init(source: .healthKit)
        age = .init(source: .healthKit)
        leanBodyMass = .init(source: .healthKit)
        restingEnergy = .init(source: .healthKit)
        activeEnergy = .init(source: .healthKit)
    }
    
    mutating func setHealthKitValue(_ value: HealthKitValue?, for type: HealthType) {
        
        switch type {
        case .weight:           weightQuantity = value?.quantity
        case .height:           heightQuantity = value?.quantity
        case .leanBodyMass:     leanBodyMassQuantity = value?.quantity
            
        case .restingEnergy:    restingEnergyValue = value?.double
        case .activeEnergy:     activeEnergyValue = value?.double
            
        case .sex:              sexValue = value?.sex
        case .age:              ageHealthKitDateComponents = value?.dateComponents

        case .maintenanceEnergy:
            maintenanceEnergy = value?.maintenanceEnergy

        default:                break
        }
    }
}

public extension Health {
    func isMissingHealthKitValue(for type: HealthType) -> Bool {
        sourceIsHealthKit(for: type) && valueIsNil(for: type)
    }
    
    func typeToFetchFromHealthKit(from old: Health) -> HealthType? {
        if old.weightSource != .healthKit, weightSource == .healthKit {
            return .weight
        }
        if old.leanBodyMassSource != .healthKit, leanBodyMassSource == .healthKit {
            return .leanBodyMass
        }
        if old.heightSource != .healthKit, heightSource == .healthKit {
            return .height
        }
        if old.restingEnergySource != .healthKit, restingEnergySource == .healthKit {
            return .restingEnergy
        }
        if old.activeEnergySource != .healthKit, activeEnergySource == .healthKit {
            return .activeEnergy
        }
        if old.sexSource != .healthKit, sexSource == .healthKit {
            return .sex
        }
        if old.ageSource != .healthKit, ageSource == .healthKit {
            return .age
        }
        return nil
    }
}

public extension Health {
    var usesHealthKit: Bool {
        restingEnergy?.source == .healthKit
        || activeEnergy?.source == .healthKit
        || age?.source == .healthKit
        || sex?.source == .healthKit
        || weight?.source == .healthKit
        || height?.source == .healthKit
        || leanBodyMass?.source == .healthKit
    }
    
    var usesHealthKitForRestingEnergy: Bool {
        switch restingEnergySource {
        case .equation:     restingEnergyEquation.usesHealthKit(in: self)
        case .healthKit:    true
        case .userEntered:  false
        }
    }
    
    var usesHealthKitForActiveEnergy: Bool {
        switch activeEnergySource {
        case .healthKit:                    true
        case .activityLevel, .userEntered:  false
        }
    }

    var usesHealthKitForMaintenanceEnergy: Bool {
        usesHealthKitForRestingEnergy || usesHealthKitForActiveEnergy
    }
    
    var usesHealthKitForWeight: Bool { weightSource == .healthKit }
    var usesHealthKitForHeight: Bool { heightSource == .healthKit }
    var usesHealthKitForSex: Bool { sexSource == .healthKit }
    var usesHealthKitForAge: Bool { ageSource == .healthKit }

    var usesHealthKitForLeanBodyMass: Bool {
        switch leanBodyMassSource {
        case .equation:         leanBodyMassEquation.usesHealthKit(in: self)
        case .fatPercentage:    usesHealthKitForWeight
        case .healthKit:        true
        case .userEntered:      false
        }
    }
}
public extension Health {
    var doesNotHaveAnyHealthKitBasedTypesSet: Bool {
        restingEnergy == nil
        && activeEnergy == nil
        && age == nil
        && sex == nil
        && weight == nil
        && height == nil
        && leanBodyMass == nil
    }
}
