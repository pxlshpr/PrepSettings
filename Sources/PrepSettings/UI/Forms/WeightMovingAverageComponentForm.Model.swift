import SwiftUI
import PrepShared

extension WeightMovingAverageComponentForm {
    @Observable class Model {
        
        let initialValue: Double?
        
        let healthModel: HealthModel

        var valueInKg: Double?
        var displayedValue: Double
        var date: Date
        
        init(value: Double?, date: Date, healthModel: HealthModel) {
            self.initialValue = value
            self.healthModel = healthModel
            self.valueInKg = value
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
        guard let valueInKg else { return }
        let converted = BodyMassUnit.kg.convert(valueInKg, to: new)
        displayedValue = converted
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
