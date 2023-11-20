import Foundation
import PrepShared

public extension HealthModel {
    func setHeightUnit(_ newValue: HeightUnit, whileEditing type: HealthType? = nil) {
        
        Task {
            switch heightSource {
            case .healthKit:
                break
//                try await setHeightFromHealthKit(using: newValue)
            case .userEntered:
                await MainActor.run {
                    if type != .height, let value = health.height?.quantity?.value {
                        let converted = health.heightUnit.convert(value, to: newValue)
                        health.height?.quantity?.value = converted
                    }
                }
            }
            
            await MainActor.run {
                health.heightUnit = newValue
            }
        }
    }

    func setEnergyUnit(_ newValue: EnergyUnit, whileEditing type: HealthType? = nil) {
        
        Task {
            switch restingEnergySource {
            case .healthKit:
//                try await setRestingEnergyFromHealthKit(using: newValue)
                break
            case .equation:
                break
            case .userEntered:
                //TODO: Convert
                break
//                await MainActor.run {
//                    if type != .weight, let value = health.weight?.quantity?.value {
//                        let converted = bodyMassUnit.convert(value, to: newValue)
//                        health.weight?.quantity?.value = converted
//                    }
//                }
            }
            
            switch activeEnergySource {
            case .healthKit:
                break
//                try await setActiveEnergyFromHealthKit(using: newValue)
            case .activityLevel:
                break
            case .userEntered:
                //TODO: Convert
                break
//                await MainActor.run {
//                    if type != .leanBodyMass, let value = health.leanBodyMass?.quantity?.value {
//                        let converted = bodyMassUnit.convert(value, to: newValue)
//                        health.leanBodyMass?.quantity?.value = converted
//                    }
//                }
            }
            
            await MainActor.run {
                health.energyUnit = newValue
            }
        }
    }
    
    func setBodyMassUnit(_ newValue: BodyMassUnit, whileEditing type: HealthType? = nil) {
        
        Task {
            switch weightSource {
            case .healthKit:
                break
//                try await setWeightFromHealthKit(using: newValue)
            case .userEntered:
                await MainActor.run {
                    if type != .weight, let value = health.weight?.quantity?.value {
                        let converted = health.bodyMassUnit.convert(value, to: newValue)
                        health.weight?.quantity?.value = converted
                    }
                }
            }
            
            switch leanBodyMassSource {
            case .healthKit:
                break
//                try await setLeanBodyMassFromHealthKit(using: newValue)
            case .equation, .fatPercentage:
                break
            case .userEntered:
                await MainActor.run {
                    if type != .leanBodyMass, let value = health.leanBodyMass?.quantity?.value {
                        let converted = health.bodyMassUnit.convert(value, to: newValue)
                        health.leanBodyMass?.quantity?.value = converted
                    }
                }
            }
            
            await MainActor.run {
                health.bodyMassUnit = newValue
            }
        }
    }
}
