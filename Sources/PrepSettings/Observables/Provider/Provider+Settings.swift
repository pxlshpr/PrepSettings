import SwiftUI
import PrepShared

public extension Provider {
    
    var metricType: GoalMetricType {
        get { settings.metricType }
        set {
            withAnimation {
                settings.metricType = newValue
            }
            saveSettings()
        }
    }
    
    var compactNutrients: [Nutrient] {
        get { settings.compactNutrients }
        set {
            withAnimation {
                settings.compactNutrients = newValue
            }
            saveSettings()
        }
    }

    var expandedMicroGroups: [MicroGroup] {
        get { settings.expandedMicroGroups }
        set {
            withAnimation {
                settings.expandedMicroGroups = newValue
            }
            saveSettings()
        }
    }
    
    //MARK: Units
    
    var heightUnit: HeightUnit {
        get { settings.heightUnit }
        set { saveHeightUnit(newValue) }
    }
    
    var bodyMassUnit: BodyMassUnit {
        get { settings.bodyMassUnit }
        set { saveBodyMassUnit(newValue) }
    }
    
    var energyUnit: EnergyUnit {
        get { settings.energyUnit }
        set { saveEnergyUnit(newValue) }
    }
}

extension Provider {
    
    func saveHeightUnit(_ heightUnit: HeightUnit) {
        settings.heightUnit = heightUnit
        saveSettings()
    }

    func saveEnergyUnit(_ energyUnit: EnergyUnit) {
        settings.energyUnit = energyUnit
        saveSettings()
    }

    func saveBodyMassUnit(_ bodyMassUnit: BodyMassUnit) {
        settings.bodyMassUnit = bodyMassUnit
        saveSettings()
    }
}

extension Provider {
    
    func isHealthKitSyncing(_ healthDetail: HealthDetail) -> Bool {
        settings.isHealthKitSyncing(healthDetail)
    }
    
    var heightIsHealthKitSynced: Bool {
        get { settings.isHealthKitSyncing(.height) }
        set { setHealthKitSyncing(for: .height, to: newValue) }
    }
    
    var weightIsHealthKitSynced: Bool {
        get { settings.isHealthKitSyncing(.weight) }
        set { setHealthKitSyncing(for: .weight, to: newValue) }
    }
    
    var leanBodyMassIsHealthKitSynced: Bool {
        get { settings.isHealthKitSyncing(.leanBodyMass) }
        set { setHealthKitSyncing(for: .leanBodyMass, to: newValue) }
    }
    
    var fatPercentageIsHealthKitSynced: Bool {
        get { settings.isHealthKitSyncing(.fatPercentage) }
        set { settings.setHealthKitSyncing(for: .fatPercentage, to: newValue) }
    }
}

extension Provider {
    func unit(for healthUnit: any HealthUnit.Type) -> (any HealthUnit)? {
        if healthUnit is BodyMassUnit.Type {
            bodyMassUnit
        } else if healthUnit is HeightUnit.Type {
            heightUnit
        } else if healthUnit is PercentUnit.Type {
            PercentUnit.percent
        } else {
            nil
        }
    }
    
    func unitString(for measurementType: MeasurementType) -> String {
        switch measurementType {
        case .height:
            heightUnit.abbreviation
        case .weight, .leanBodyMass:
            bodyMassUnit.abbreviation
        case .fatPercentage:
            "%"
        case .energy:
            energyUnit.abbreviation
        }
    }
    
    func secondUnitString(for measurementType: MeasurementType) -> String? {
        switch measurementType {
        case .height:
            heightUnit.secondaryUnit
        case .weight, .leanBodyMass:
            bodyMassUnit.secondaryUnit
        case .fatPercentage:
            nil
        case .energy:
            nil
        }
    }
}

extension Provider {
    func energyString(_ kcal: Double) -> String {
        "\(EnergyUnit.kcal.convert(kcal, to: energyUnit).formattedEnergy) \(energyUnit.abbreviation)"
    }
    
    func bodyMassString(_ kg: Double) -> String {
        "\(BodyMassUnit.kg.convert(kg, to: bodyMassUnit).cleanHealth) \(bodyMassUnit.abbreviation)"
    }
}
