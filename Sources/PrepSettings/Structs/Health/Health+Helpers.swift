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
        case .sex:                  sexValue != nil && sexValue != .notSpecified
        case .age:                  ageValue != nil
        case .weight:               weight?.quantity?.value != nil
        case .leanBodyMass:         leanBodyMass?.quantity?.value != nil
        case .height:               height?.quantity?.value != nil
        case .fatPercentage:        fatPercentage != nil
        case .restingEnergy:        restingEnergy?.value != nil
        case .activeEnergy:         activeEnergy?.value != nil
        case .maintenanceEnergy:
            haveValue(for: .restingEnergy) && haveValue(for: .activeEnergy)
        }
    }
}
