import SwiftUI
import CoreData
import OSLog

import PrepShared

@Observable public class SettingsProvider {
    
    public static let shared = SettingsProvider()
    public static var energyUnit: EnergyUnit { shared.energyUnit }
    public static var bodyMassUnit: BodyMassUnit { shared.bodyMassUnit }
    public static var heightUnit: HeightUnit { shared.heightUnit }

    public var settings: Settings = .default 

    var fetchHandler: SettingsFetchHandler? = nil
    var saveHandler: SettingsSaveHandler? = nil

    public init() { 
        if let data = UserDefaults.standard.object(forKey: "Settings") as? Data,
           let settings = try? JSONDecoder().decode(Settings.self, from: data) {
            self.settings = settings
        }
    }
}

public extension SettingsProvider {
    
    static func configure(
        fetchHandler: @escaping SettingsFetchHandler,
        saveHandler: @escaping SettingsSaveHandler
    ) {
        shared.configure(fetchHandler: fetchHandler, saveHandler: saveHandler)
    }
    
    static func save() {
        shared.save()
    }
    
    static func fetch() {
        shared.fetch()
    }
}

extension SettingsProvider {
    
    func configure(
        fetchHandler: @escaping SettingsFetchHandler,
        saveHandler: @escaping SettingsSaveHandler
    ) {
        self.fetchHandler = fetchHandler
        self.saveHandler = saveHandler
        fetch()
    }

    func save() {
        guard let saveHandler else { return }
        Task.detached(priority: .background) {
            
            /// Save in the backend
            try await saveHandler(self.settings)
            
            /// Also save in UserDefaults for quick access on init
            self.saveSettingsToUserDefaults()
        }
    }
    
    func saveSettingsToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(self.settings) {
            UserDefaults.standard.set(encoded, forKey: "Settings")
        }
    }
    
    func fetch() {
        guard let fetchHandler else { return }
        Task {
            let settings = try await fetchHandler()
            await MainActor.run {
                let hasChanged = settings != self.settings
                self.settings = settings
                
                /// Crucial to do this after setting `settings`
                if hasChanged {
                    saveSettingsToUserDefaults()
                    post(.didUpdateSettings)
                }
            }
        }
    }
}

public extension SettingsProvider {
    
    var metricType: GoalMetricType {
        get { settings.metricType }
        set {
            withAnimation {
                settings.metricType = newValue
            }
            save()
        }
    }
    
    var compactNutrients: [Nutrient] {
        get { settings.compactNutrients }
        set {
            withAnimation {
                settings.compactNutrients = newValue
            }
            save()
        }
    }

    var expandedMicroGroups: [MicroGroup] {
        get { settings.expandedMicroGroups }
        set {
            withAnimation {
                settings.expandedMicroGroups = newValue
            }
            save()
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

extension SettingsProvider {
    
    func saveHeightUnit(_ heightUnit: HeightUnit) {
        settings.heightUnit = heightUnit
        save()
    }

    func saveEnergyUnit(_ energyUnit: EnergyUnit) {
        settings.energyUnit = energyUnit
        save()
    }

    func saveBodyMassUnit(_ bodyMassUnit: BodyMassUnit) {
        settings.bodyMassUnit = bodyMassUnit
        save()
    }
}

extension SettingsProvider {
    
    func isHealthKitSyncing(_ healthDetail: HealthDetail) -> Bool {
        settings.isHealthKitSyncing(healthDetail)
    }
    
    func setHealthKitSyncing(for healthDetail: HealthDetail, to isOn: Bool) {
        settings.setHealthKitSyncing(for: healthDetail, to: isOn)
        save()
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

extension SettingsProvider {
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

extension SettingsProvider {
    func energyString(_ kcal: Double) -> String {
        "\(EnergyUnit.kcal.convert(kcal, to: energyUnit).formattedEnergy) \(energyUnit.abbreviation)"
    }
    
    func bodyMassString(_ kg: Double) -> String {
        "\(BodyMassUnit.kg.convert(kg, to: bodyMassUnit).cleanHealth) \(bodyMassUnit.abbreviation)"
    }
}
