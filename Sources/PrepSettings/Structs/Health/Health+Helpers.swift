import SwiftUI
import PrepShared

public extension Health {
    
    var restingEnergy: RestingEnergy? {
        get {
            maintenance?.estimated.restingEnergy
        }
        set {
            guard let newValue else {
                maintenance = nil
                return
            }
            maintenance?.estimated.restingEnergy = newValue
        }
    }
    
    
    var activeEnergy: ActiveEnergy? {
        get {
            maintenance?.estimated.activeEnergy
        }
        set {
            guard let newValue else {
                maintenance = nil
                return
            }
            maintenance?.estimated.activeEnergy = newValue
        }
    }
    
    var tdeeRequiredString: String? {
        switch (restingEnergyValue, activeEnergyValue) {
        case (.some, .some): nil
        case (.some, .none): "Active energy required"
        case (.none, .some): "Resting energy required"
        case (.none, .none): "Resting and active energy required"
        }
    }
    
    func haveValue(for type: HealthType) -> Bool {
        switch type {
        case .sex:                  sexValue != nil && sexValue != .other
        case .age:                  ageValue != nil
        case .weight:               weight?.quantity?.value != nil
        case .leanBodyMass:         leanBodyMass?.quantity?.value != nil
        case .height:               height?.quantity?.value != nil
        case .fatPercentage:        fatPercentage != nil
        case .restingEnergy:        restingEnergy?.value != nil
        case .activeEnergy:         activeEnergy?.value != nil
        case .maintenance:    haveValue(for: .restingEnergy) && haveValue(for: .activeEnergy)
        case .pregnancyStatus:      pregnancyStatus != nil
        case .isSmoker:             isSmoker != nil
        }
    }
}

extension Health {
    
    mutating func add(_ type: HealthType) {
        switch type {
        case .age:
            ageSource = .userEnteredDateOfBirth
        case .sex:
            sex = .init(source: .userEntered, value: .female)
        case .weight:
//            let initial = BodyMassUnit.kg.convert(DefaultWeightInKg, to: bodyMassUnit)
            weight = .init(source: .userEntered, quantity: .init(value: DefaultWeightInKg))
        case .height:
//            let initial = HeightUnit.cm.convert(DefaultHeightInCm, to: heightUnit)
            height = .init(source: .userEntered, quantity: .init(value: DefaultHeightInCm))
        case.leanBodyMass:
            leanBodyMassSource = .equation
        case .pregnancyStatus:
            pregnancyStatus = .pregnant
            isSmoker = nil
        case .isSmoker:
            isSmoker = false
        case .maintenance:
            maintenance = .init(prefersAdaptive: true)
//            maintenance?.estimated.restingEnergy = .init(source: .userEntered, value: 1600)
//            maintenance?.estimated.activeEnergy = .init(source: .userEntered, value: 400)
        default:
            break
        }
    }
    
    mutating func remove(_ type: HealthType) {
        switch type {
        case .maintenance: maintenance = nil
        case .sex:              sex = nil
        case .age:              age = nil
        case .weight:           weight = nil
        case .leanBodyMass:     leanBodyMass = nil
        case .fatPercentage:    fatPercentage = nil
        case .height:           height = nil
        case .pregnancyStatus:  pregnancyStatus = nil
        case .isSmoker:         isSmoker = nil
        default:                break
        }
    }
}

extension Health {
    func hasType(_ type: HealthType) -> Bool {
        switch type {
        case .maintenance:    restingEnergy != nil && activeEnergy != nil
        case .activeEnergy:         activeEnergy != nil
        case .restingEnergy:        restingEnergy != nil
        case .sex:                  sex != nil
        case .age:                  age != nil
        case .weight:               weight != nil
        case .leanBodyMass:         leanBodyMass != nil
        case .fatPercentage:        fatPercentage != nil
        case .height:               height != nil
        case .pregnancyStatus:      pregnancyStatus != nil
        case .isSmoker:             isSmoker != nil
        }
    }
    
    
    func hasValue(for type: HealthType) -> Bool {
        switch type {
        case .maintenance:    hasMaintenanceValue
        case .restingEnergy:        restingEnergy?.value != nil
        case .activeEnergy:         activeEnergy?.value != nil
        case .sex:                  sex?.value != nil
        case .age:                  age?.value != nil
        case .weight:               weight?.quantity?.value != nil
        case .leanBodyMass:         leanBodyMass?.quantity?.value != nil
        case .fatPercentage:        fatPercentage != nil
        case .height:               height?.quantity?.value != nil
        case .pregnancyStatus:      pregnancyStatus != nil
        case .isSmoker:             isSmoker != nil
        }
    }
    
    var maintenanceValueInKcal: Double? {
        if prefersAdaptiveMaintenance,
           let value = maintenance?.value {
            value
        } else if let value = estimatedMaintenanceInKcal {
            value
        } else {
            nil
        }
    }
    
    func maintenanceValue(in unit: EnergyUnit) -> Double? {
        guard let maintenanceValueInKcal else { return nil }
        return EnergyUnit.kcal.convert(maintenanceValueInKcal, to: unit)
    }
    
    func summaryDetail(for type: HealthType) -> String? {
        
        switch type {
        case .maintenance:
            guard let value = maintenanceValue(in: SettingsStore.energyUnit) else { return nil }
            return "\(value.formattedEnergy) \(SettingsStore.energyUnit.abbreviation)"
            
        case .sex:
            guard let sex = sex?.value else { return nil }
            return sex.name
            
        case .age:
            guard let age = age?.value else { return nil }
            return "\(age) years"
            
        case .weight:
            guard let kg = weight?.quantity?.value else { return nil }
            let unit = SettingsStore.bodyMassUnit
            let value = BodyMassUnit.kg.convert(kg, to: unit)
            return "\(value.clean) \(unit.abbreviation)"
            
        case .leanBodyMass:
            guard let kg = leanBodyMass?.quantity?.value else { return nil }
            let unit = SettingsStore.bodyMassUnit
            let value = BodyMassUnit.kg.convert(kg, to: unit)
            return "\(value.clean) \(unit.abbreviation)"
            
        case .height:
            guard let cm = height?.quantity?.value else { return nil }
            let unit = SettingsStore.heightUnit
            let value = HeightUnit.cm.convert(cm, to: unit)
            return "\(value.clean) \(unit.abbreviation)"
            
        case .pregnancyStatus:
            guard let pregnancyStatus else { return nil }
            return pregnancyStatus.name
            
        case .isSmoker:
            guard let isSmoker else { return nil }
            return isSmoker ? "Yes" : "No"
            
        case .restingEnergy:
            guard let kcal = restingEnergy?.value else { return nil }
            let unit = SettingsStore.energyUnit
            let value = EnergyUnit.kcal.convert(kcal, to: unit)
            return "\(value.formattedEnergy) \(unit.abbreviation)"
            
        case .activeEnergy:
            guard let kcal = activeEnergy?.value else { return nil }
            let unit = SettingsStore.energyUnit
            let value = EnergyUnit.kcal.convert(kcal, to: unit)
            return "\(value.formattedEnergy) \(unit.abbreviation)"
            
        default:
            return nil
        }
    }
    
    var isUsingCalculatedMaintenance: Bool {
        prefersAdaptiveMaintenance
        && hasCalculatedMaintenance
    }
    
    var hasCalculatedAndEstimatedMaintenance: Bool {
        hasCalculatedMaintenance && hasEstimatedMaintenance
    }

    var hasCalculatedMaintenance: Bool {
        maintenance?.adaptive.value != nil
        && maintenance?.adaptive.error == nil
    }
    
    var hasEstimatedMaintenance: Bool {
        tdeeRequiredString == nil
        && estimatedMaintenanceInKcal != nil
    }
    
    var hasMaintenanceValue: Bool {
        hasCalculatedMaintenance || hasEstimatedMaintenance
    }
}

extension Health {
    func bodyMassValue(for type: BodyMassType, in unit: BodyMassUnit? = nil) -> Double? {
        let value: Double? = switch type {
        case .weight:   weight?.quantity?.value
        case .leanMass: leanBodyMass?.quantity?.value
        }
        
        guard let value else { return nil}
        
        return if let unit {
            BodyMassUnit.kg.convert(value, to: unit)
        } else {
            value
        }
    }
}
