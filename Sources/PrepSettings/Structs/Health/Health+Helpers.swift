import SwiftUI
import PrepShared

public extension Health {
    
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
        case .energyBurn:    haveValue(for: .restingEnergy) && haveValue(for: .activeEnergy)
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
            let initial = BodyMassUnit.kg.convert(DefaultWeightInKg, to: bodyMassUnit)
            weight = .init(source: .userEntered, quantity: .init(value: initial))
        case .height:
            let initial = HeightUnit.cm.convert(DefaultHeightInCm, to: heightUnit)
            height = .init(source: .userEntered, quantity: .init(value: initial))
        case.leanBodyMass:
            leanBodyMassSource = .equation
        case .pregnancyStatus:
            pregnancyStatus = .pregnant
            isSmoker = nil
        case .isSmoker:
            isSmoker = false
        case .energyBurn:
            restingEnergy = .init(source: .userEntered, value: 1600)
            activeEnergy = .init(source: .userEntered, value: 400)
        default:
            break
        }
    }
    
    mutating func remove(_ type: HealthType) {
        switch type {
        case .energyBurn:
            restingEnergy = nil
            activeEnergy = nil
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
        case .energyBurn:    restingEnergy != nil && activeEnergy != nil
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
}
