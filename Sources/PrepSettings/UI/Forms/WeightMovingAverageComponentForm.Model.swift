import SwiftUI
import PrepShared

extension WeightMovingAverageComponentForm {
    @Observable class Model {
        
        let initialValue: Double?
        
        var valueInKg: Double?
        var displayedValue: Double {
            didSet {
                valueInKg = SettingsStore.shared.bodyMassUnit.convert(displayedValue, to: .kg)
            }
        }
        var date: Date
        
        init(value: Double?, date: Date) {
            self.initialValue = value
            self.valueInKg = if let value {
                SettingsStore.shared.bodyMassUnit.convert(value, to: .kg)
            } else { nil }
            self.displayedValue = value ?? 0
            self.date = date
        }
    }
}

extension WeightMovingAverageComponentForm.Model {
    
    var isNotDirty: Bool {
        valueInKg == initialValue
    }
    
    var isSaveDisabled: Bool {
        if isNotDirty { return true }
        guard let valueInKg else { return false }
        return valueInKg <= 0
    }
    
    func bodyMassUnitChanged(old: BodyMassUnit, new: BodyMassUnit) {
        /// Convert the `valueInKg` value stored internally to reflect the new unit
        let converted = new.convert(displayedValue, to: .kg)
        self.valueInKg = converted
    }
    
    var weightStonesComponent: Int {
        get { Int(displayedValue.whole) }
        set {
            let value = Double(newValue) + (weightPoundsComponent / PoundsPerStone)
            self.valueInKg = value
            displayedValue = value
        }
    }
    
    var weightPoundsComponent: Double {
        get { displayedValue.fraction * PoundsPerStone }
        set {
            let newValue = min(newValue, PoundsPerStone-1)
            let value = Double(weightStonesComponent) + (newValue / PoundsPerStone)
            self.valueInKg = value
            displayedValue = value
        }
    }
}
