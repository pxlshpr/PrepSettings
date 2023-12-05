import SwiftUI
import PrepShared

public extension HealthModel {
    
    //MARK: Energy Burn
    var maintenanceEnergyIsAdaptive: Bool {
        get { health.prefersAdaptiveMaintenance }
        set {
            withAnimation {
                health.prefersAdaptiveMaintenance = newValue
            }
            Task {
//                await MainActor.run {
//                    withAnimation {
//                        health.maintenanceEnergyIsAdaptive = newValue
//                    }
//                }
                if newValue {
//                    try await calculateAdaptiveMaintenance()
                } else {
//                    await MainActor.run {
//                        withAnimation {
//                            health.maintenanceEnergy?.error = nil
//                        }
//                    }
                }
            }
        }
    }

    var maintenanceWeightChangeDeltaIsNegative: Bool {
        guard let maintenanceWeightChangeDelta else { return false }
        return maintenanceWeightChangeDelta < 0
    }

    var maintenanceWeightChangeDeltaType: DeltaType {
        guard let delta = maintenanceWeightChangeDelta else { return .zero }
        return delta < 0 ? .negative : .positive
    }

    var maintenanceWeightChangeDelta: Double? {
        get { health.maintenance?.adaptive.weightChange.delta }
        set {
            Task {
                await MainActor.run {
                    withAnimation {
                        health.maintenance?.adaptive.weightChange.delta = newValue
                    }
                }
                
                try await calculateAdaptiveMaintenance()
            }
        }
    }
    
    var maintenanceWeightChangeType: WeightChangeType {
        get { health.maintenance?.adaptive.weightChange.type ?? .usingWeights }
        set {
            Task {
                await MainActor.run {
                    withAnimation {
                        health.maintenance?.adaptive.weightChange.type = newValue
                    }
                }
                
                switch newValue {
                case .userEntered:
                    /// Reset the weight samples
                    health.maintenance?.adaptive.weightChange.current = .init()
                    health.maintenance?.adaptive.weightChange.previous = .init()
                case .usingWeights:
                    break
                }
                
                try await calculateAdaptiveMaintenance()
            }
        }
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
        set { health.ageSource = newValue }
    }
    
    var sexSource: HealthSource {
        get { health.sexSource }
        set { health.sexSource = newValue }
    }

    var weightSource: HealthSource {
        get { health.weightSource }
        set { health.weightSource = newValue }
    }

    var heightSource: HealthSource {
        get { health.heightSource }
        set { health.heightSource = newValue }
    }

    var leanBodyMassSource: LeanBodyMassSource {
        get { health.leanBodyMassSource }
        set { health.leanBodyMassSource = newValue }
    }

    var restingEnergySource: RestingEnergySource {
        get { health.restingEnergySource }
        set { health.restingEnergySource = newValue }
    }
    
    var activeEnergySource: ActiveEnergySource {
        get { health.activeEnergySource }
        set { health.activeEnergySource = newValue }
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
    
//    var maintenanceEnergyAdaptiveValue: Double? {
//        get { health.maintenanceEnergyAdaptiveValue }
//        set { health.maintenanceEnergyAdaptiveValue = newValue }
//    }
//
//    var maintenanceEnergyAdaptiveError: MaintenanceCalculationError? {
//        get { health.maintenanceEnergyAdaptiveError }
//        set { health.maintenanceEnergyAdaptiveError = newValue }
//    }

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

    var ageValue: Int? {
        get { health.ageValue }
        set {
            guard let newValue else {
                health.ageValue = nil
                health.age?.dateOfBirthComponents = nil
                return
            }
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
    
    var fatPercentageValue: Double? {
        get { health.fatPercentage }
        set { health.fatPercentage = newValue }
    }

    var weightValue: Double? {
        get { health.weightQuantity?.value }
        set { health.weightQuantity = .init(value: newValue) }
    }
    
    var leanBodyMassValue: Double? {
        get { health.leanBodyMassQuantity?.value }
        set { health.leanBodyMassQuantity = .init(value: newValue) }
    }
    
    var heightValue: Double? {
        get { health.heightQuantity?.value }
        set { health.heightQuantity = .init(value: newValue) }
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
