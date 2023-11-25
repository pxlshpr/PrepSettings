import SwiftUI
import PrepShared

extension WeightMovingAverageComponentForm {
    @Observable class Model {
        
        let initialValue: Double?
        let initialUnit: BodyMassUnit
        let healthModel: HealthModel
        let settingsStore: SettingsStore

        var value: Double?
        var displayedValue: Double {
            didSet {
                value = displayedValue
            }
        }
        var date: Date
        
        init(value: Double?, date: Date, healthModel: HealthModel, settingsStore: SettingsStore) {
            self.initialValue = value
            self.initialUnit = settingsStore.bodyMassUnit
            self.healthModel = healthModel
            self.settingsStore = settingsStore
            self.value = value
            self.displayedValue = value ?? 0
            self.date = date
        }
    }
}

extension WeightMovingAverageComponentForm.Model {
    
    var isNotDirty: Bool {
        value == initialValue
        && initialUnit == settingsStore.bodyMassUnit
    }
    
    var isSaveDisabled: Bool {
        if isNotDirty { return true }
        guard let value else { return false }
        return value <= 0
    }
    
    func bodyMassUnitChanged(old: BodyMassUnit, new: BodyMassUnit) {
        guard let value else { return }
        let converted = old.convert(value, to: new)
        self.value = converted
        displayedValue = converted
    }
    
    var weightStonesComponent: Int {
        get { Int(displayedValue.whole) }
        set {
            let value = Double(newValue) + (weightPoundsComponent / PoundsPerStone)
            self.value = value
            displayedValue = value
        }
    }
    
    var weightPoundsComponent: Double {
        get { displayedValue.fraction * PoundsPerStone }
        set {
            let newValue = min(newValue, PoundsPerStone-1)
            let value = Double(weightStonesComponent) + (newValue / PoundsPerStone)
            self.value = value
            displayedValue = value
        }
    }
}
