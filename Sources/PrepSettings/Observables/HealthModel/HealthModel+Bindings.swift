import SwiftUI
import PrepShared

public extension HealthModel {
    
    var restingEnergyUnit: EnergyUnit {
        get { health.energyUnit }
        set { setEnergyUnit(newValue, whileEditing: .restingEnergy) }
    }

    var activeEnergyUnit: EnergyUnit {
        get { health.energyUnit }
        set { setEnergyUnit(newValue, whileEditing: .activeEnergy) }
    }

    var healthWeightUnit: BodyMassUnit {
        get { health.bodyMassUnit }
        set { setBodyMassUnit(newValue, whileEditing: .weight) }
    }
    
    var healthHeightUnit: HeightUnit {
        get { health.heightUnit }
        set { setHeightUnit(newValue, whileEditing: .height) }
    }
    
    var healthLeanBodyMassUnit: BodyMassUnit {
        get { health.bodyMassUnit }
        set { setBodyMassUnit(newValue, whileEditing: .leanBodyMass) }
    }
    
    //MARK: Interval Types
    
    var restingEnergyIntervalType: HealthIntervalType {
        get { health.restingEnergyIntervalType }
        set {
            Task {
                await MainActor.run {
                    health.restingEnergyIntervalType = newValue
                }
                try await setTypeFromHealthKit(.restingEnergy)
            }
        }
    }
    
    var activeEnergyIntervalType: HealthIntervalType {
        get { health.activeEnergyIntervalType }
        set {
            Task {
                await MainActor.run {
                    health.activeEnergyIntervalType = newValue
                }
                try await setTypeFromHealthKit(.activeEnergy)
            }
        }
    }

    //MARK: Interval Periods
    
    var restingEnergyIntervalPeriod: HealthPeriod {
        get { health.restingEnergyIntervalPeriod }
        set {
            Task {
                await MainActor.run {
                    health.restingEnergyIntervalPeriod = newValue
                }
                try await setTypeFromHealthKit(.restingEnergy)
            }
        }
    }

    var activeEnergyIntervalPeriod: HealthPeriod {
        get { health.activeEnergyIntervalPeriod }
        set {
            Task {
                await MainActor.run {
                    health.activeEnergyIntervalPeriod = newValue
                }
                try await setTypeFromHealthKit(.activeEnergy)
            }
        }
    }

    //MARK: Interval Value
    
    var restingEnergyIntervalValue: Int {
        get { health.restingEnergyIntervalValue }
        set {
            Task {
                await MainActor.run {
                    withAnimation {
                        health.restingEnergyIntervalValue = newValue
                    }
                }
                try await setTypeFromHealthKit(.restingEnergy)
            }
        }
    }

    var activeEnergyIntervalValue: Int {
        get { health.activeEnergyIntervalValue }
        set {
            Task {
                await MainActor.run {
                    withAnimation {
                        health.activeEnergyIntervalValue = newValue
                    }
                }
                try await setTypeFromHealthKit(.activeEnergy)
            }
        }
    }
    
    //MARK: Sources
    
    var ageSource: AgeSource {
        get { health.ageSource }
        set {
//            Task {
//                await MainActor.run {
                    health.ageSource = newValue
//                }
//                if newValue == .healthKit {
//                    try await setAgeFromHealthKit()
//                }
//                if newValue != .userEnteredDateOfBirth {
//                    health.ageDateOfBirth = nil
//                }
//            }
        }
    }
    
    var sexSource: HealthSource {
        get { health.sexSource }
        set {
//            Task {
//                await MainActor.run {
                    health.sexSource = newValue
//                }
//                if newValue == .healthKit {
//                    try await setSexFromHealthKit()
//                }
//            }
        }
    }

    var weightSource: HealthSource {
        get { health.weightSource }
        set {
//            Task {
//                await MainActor.run {
                    health.weightSource = newValue
//                }
//                if newValue == .healthKit {
//                    try await setWeightFromHealthKit()
//                }
//            }
        }
    }

    var heightSource: HealthSource {
        get { health.heightSource }
        set {
//            Task {
//                await MainActor.run {
                    health.heightSource = newValue
//                }
//                if newValue == .healthKit {
//                    try await setHeightFromHealthKit()
//                }
//            }
        }
    }

    var leanBodyMassSource: LeanBodyMassSource {
        get { health.leanBodyMassSource }
        set {
//            Task {
//                await MainActor.run {
                    health.leanBodyMassSource = newValue
//                }
//                switch leanBodyMassSource {
//                case .healthKit:
//                    try await setLeanBodyMassFromHealthKit()
//                case .equation, .fatPercentage, .userEntered:
//                    break
//                }
//            }
        }
    }

    var restingEnergySource: RestingEnergySource {
        get { health.restingEnergySource }
        set {
//            Task {
//                await MainActor.run {
                    health.restingEnergySource = newValue
//                }
//                switch restingEnergySource {
//                case .healthKit:
//                    try await setRestingEnergyFromHealthKit()
//                case .equation, .userEntered:
//                    break
//                }
//            }
        }
    }
    
    var activeEnergySource: ActiveEnergySource {
        get { health.activeEnergySource }
        set {
//            Task {
//                await MainActor.run {
                    health.activeEnergySource = newValue
//                }
//                switch activeEnergySource {
//                case .healthKit:
//                    try await setActiveEnergyFromHealthKit()
//                case .activityLevel, .userEntered:
//                    break
//                }
//            }
        }
    }
    
    //MARK: Equations
    
    var leanBodyMassEquation: LeanBodyMassEquation {
        get { health.leanBodyMassEquation }
        set { health.leanBodyMassEquation = newValue }
    }

    var restingEnergyEquation: RestingEnergyEquation {
        get { health.restingEnergyEquation }
        set { health.restingEnergyEquation = newValue }
    }

    var activeEnergyActivityLevel: ActivityLevel {
        get { health.activeEnergyActivityLevel }
        set { health.activeEnergyActivityLevel = newValue }
    }

    //MARK: Texts
    
    var leanBodyMassHealthLinkTitle: String {
        if leanBodyMassSource.params.count == 1, let param = leanBodyMassSource.params.first {
            param.name
        } else {
            "Health Details"
        }
    }

    //MARK: Values
    
    var isSmoker: Bool {
        get { health.isSmoker ?? false }
        set { health.isSmoker = newValue }
    }
    
    var restingEnergyValue: Double {
        get { health.restingEnergyValue ?? 0 }
        set { health.restingEnergyValue = newValue }
    }

    var activeEnergyValue: Double {
        get { health.activeEnergyValue ?? 0 }
        set { health.activeEnergyValue = newValue }
    }

    var ageValue: Int {
        get { health.ageValue ?? 0 }
        set {
            health.ageValue = newValue
            health.age?.dateOfBirthComponents = newValue.dateOfBirthComponentsForAge
        }
    }

    var sexValue: Sex? {
        get { health.sexValue }
        set { health.sexValue = newValue }
    }

    var pregnancyStatus: PregnancyStatus? {
        get { health.pregnancyStatus }
        set { health.pregnancyStatus = newValue }
    }
    
    var weightValue: Double {
        get { health.weightQuantity?.value ?? 0 }
        set { health.weightQuantity = .init(value: newValue) }
    }
    
    var weightStonesComponent: Int {
        get { Int(weightValue.whole) }
        set {
            let value = Double(newValue) + (weightPoundsComponent / PoundsPerStone)
            health.weightQuantity = .init(value: value)
        }
    }
    
    var weightPoundsComponent: Double {
        get { weightValue.fraction * PoundsPerStone }
        set {
            let newValue = min(newValue, PoundsPerStone-1)
            let value = Double(weightStonesComponent) + (newValue / PoundsPerStone)
            health.weightQuantity = .init(value: value)
        }
    }
    
    var leanBodyMassValue: Double {
        get { health.leanBodyMassQuantity?.value ?? 0 }
        set { health.leanBodyMassQuantity = .init(value: newValue) }
    }

    var fatPercentageValue: Double {
        get { health.fatPercentage ?? 0 }
        set { health.fatPercentage = newValue }
    }

    var leanBodyMassStonesComponent: Int {
        get { Int(leanBodyMassValue.whole) }
        set {
            let value = Double(newValue) + (leanBodyMassPoundsComponent / PoundsPerStone)
            health.leanBodyMassQuantity = .init(value: value)
        }
    }
    
    var leanBodyMassPoundsComponent: Double {
        get { leanBodyMassValue.fraction * PoundsPerStone }
        set {
            let newValue = min(newValue, PoundsPerStone-1)
            let value = Double(leanBodyMassStonesComponent) + (newValue / PoundsPerStone)
            health.leanBodyMassQuantity = .init(value: value)
        }
    }
    
    var heightValue: Double {
        get { health.heightQuantity?.value ?? 0 }
        set { health.heightQuantity = .init(value: newValue) }
    }
    
    var heightFeetComponent: Int {
        get { Int(heightValue.whole) }
        set {
            let value = Double(newValue) + (heightCentimetersComponent / InchesPerFoot)
            health.heightQuantity = .init(value: value)
        }
    }
    
    var heightCentimetersComponent: Double {
        get { heightValue.fraction * InchesPerFoot }
        set {
            let newValue = min(newValue, InchesPerFoot-1)
            let value = Double(heightFeetComponent) + (newValue / InchesPerFoot)
            health.heightQuantity = .init(value: value)
        }
    }
}

public extension HealthModel {
    var activeEnergyInterval: HealthInterval? {
        get { health.activeEnergy?.interval }
        set { }
    }
    var restingEnergyInterval: HealthInterval? {
        get { health.restingEnergy?.interval }
        set { }
    }
}
