import SwiftUI
import PrepShared

struct HeightField: View {
    
    @Binding var unit: HeightUnit
    @Binding var valueInCm: Double?
    
    var body: some View {
        HealthNumberField(
            unitBinding: $unit,
            valueBinding: valueInDisplayedUnit,
            firstComponentBinding: feetComponent,
            secondComponentBinding: centimetersComponent
        )
    }
    
    var valueInDisplayedUnit: Binding<Double?> {
        Binding<Double?>(
            get: {
                guard let valueInCm else { return nil }
                return HeightUnit.cm.convert(valueInCm, to: unit)
            },
            set: { newValue in
                guard let newValue else {
                    valueInCm = nil
                    return
                }
                let valueInCm = unit.convert(newValue, to: .cm)
                self.valueInCm = valueInCm
            }
        )
    }
    
    var valueInFeet: Double? {
        guard let valueInCm else { return nil }
        return HeightUnit.cm.convert(valueInCm, to: .ft)
    }
    
    var feetComponent: Binding<Int?> {
        Binding<Int?>(
            get: {
                guard let valueInFeet else { return nil }
                return Int(valueInFeet.whole)
            },
            set: { newValue in
                guard let newValue, let centimeters = centimetersComponent.wrappedValue else {
                    valueInCm = nil
                    return
                }
                let valueInFeet = Double(newValue) + (centimeters / InchesPerFoot)
                valueInCm = HeightUnit.ft.convert(valueInFeet, to: .cm)
            }
        )
    }
    
    var centimetersComponent: Binding<Double?> {
        Binding<Double?>(
            get: { 
                guard let valueInFeet else { return nil }
                return valueInFeet.fraction * InchesPerFoot
            },
            set: { newValue in
                guard let newValue, let feet = feetComponent.wrappedValue else {
                    valueInCm = nil
                    return
                }
                let value = min(newValue, InchesPerFoot-1)
                let valueInFeet = Double(feet) + (value / InchesPerFoot)
                valueInCm = HeightUnit.ft.convert(valueInFeet, to: .cm)
            }
        )
    }
}
