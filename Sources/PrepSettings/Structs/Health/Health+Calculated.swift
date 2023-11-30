import SwiftUI
import PrepShared

public extension Health {

    //MARK: Recalculators
    
    mutating func recalculate() {
        cleanup()
        
        calculateAge()
        calculateLeanBodyMass()
        calculateRestingEnergy()
        calculateActiveEnergy()

        updatedAt = Date.now
    }
    
    mutating func calculateAge() {
        guard let source = age?.source,
              source == .userEnteredDateOfBirth,
              let components = age?.dateOfBirthComponents
        else {
            return
        }
        withAnimation {
            age = Age(
                source: .userEnteredDateOfBirth,
                dateOfBirthComponents: components,
                value: components.age
            )
        }
    }
    
    mutating func calculateLeanBodyMass() {
        
        func setQuantity(_ quantity: Quantity?) {
            withAnimation {
                leanBodyMassQuantity = quantity
            }
        }
        
        func clearQuantity() {
            setQuantity(nil)
        }

        print("calculating lean body mass")
        
        guard let source = leanBodyMass?.source else {
//            leanBodyMass = .init(
//                source: .default,
//                equation: .default,
//                quantity: nil
//            )
            return
        }

        switch source {
        case .healthKit:
            break
        case .equation:
            guard let equation = leanBodyMass?.equation,
                  let weightValue,
                  let heightValue,
                  let sex = sex?.value
            else {
                clearQuantity()
                return
            }
            let valueInKg = equation.calculateInKg(
                sexIsFemale: sex == .female,
                weightInKg: weightValue,
                heightInCm: heightValue
            )
//            let value = BodyMassUnit.kg.convert(valueInKg, to: bodyMassUnit)
            setQuantity(.init(value: valueInKg))
            
        case .fatPercentage:
            guard let fatPercentage,
                  fatPercentage > 0,
                  fatPercentage < 100,
                  let weightQuantity
            else {
                clearQuantity()
                return
            }
            let leanPercentage = 100.0 - fatPercentage
            setQuantity(.init(value: (leanPercentage/100.0) * weightQuantity.value))
            
        case .userEntered:
            break
        }
    }
    
    mutating func calculateActiveEnergy() {
        
        func setValue(_ value: Double?) {
            withAnimation {
                self.activeEnergyValue = value
            }
        }

        guard activeEnergy != nil, activeEnergySource == .activityLevel else { return }
        guard let restingEnergyValue else {
            setValue(nil)
            return
        }
        
        let total = activeEnergyActivityLevel.scaleFactor * restingEnergyValue
        setValue(total - restingEnergyValue)
    }
    
    mutating func calculateRestingEnergy() {
        
        func setValue(_ value: Double?) {
            withAnimation {
                restingEnergyValue = value
            }
        }
        
        guard restingEnergy != nil, restingEnergySource == .equation else { return }
        
        let value: Double? = switch restingEnergyEquation {
        case .katchMcardle, .cunningham:
            if let leanBodyMassValue {
                restingEnergyEquation.calculate(
                    lbmInKg: leanBodyMassValue,
                    energyUnit: .kcal
//                    energyUnit: energyUnit
                )
            } else {
                nil
            }
        case .henryOxford, .schofield:
            if let age = age?.value, let weightValue, let sex = sex?.value {
                restingEnergyEquation.calculate(
                    age: age,
                    weightInKg: weightValue,
                    sexIsFemale: sex == .female,
                    energyUnit: .kcal
//                    energyUnit: energyUnit
                )
            } else {
                nil
            }
        default:
            if let age = age?.value, let weightValue, let heightValue, let sex = sex?.value {
                restingEnergyEquation.calculate(
                    age: age,
                    weightInKg: weightValue,
                    heightInCm: heightValue,
                    sexIsFemale: sex == .female,
                    energyUnit: .kcal
//                    energyUnit: energyUnit
                )
            } else {
                nil
            }
        }
        
        if let value {
            setValue(value)
        } else {
            setValue(nil)
        }
    }
}
