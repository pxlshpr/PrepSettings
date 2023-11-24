import SwiftUI
import PrepShared

struct ManualHeightField: View {
    
    @Binding var unit: HeightUnit
    @Binding var valueInCm: Double
    
    var body: some View {
        ManualHealthField(
            unitBinding: $unit,
            valueBinding: valueInDisplayedUnit,
            firstComponentBinding: feetComponent,
            secondComponentBinding: centimetersComponent
        )
    }
    
    var valueInDisplayedUnit: Binding<Double> {
        Binding<Double>(
            get: { HeightUnit.cm.convert(valueInCm, to: unit) },
            set: {
                let valueInCm = unit.convert($0, to: .cm)
                self.valueInCm = valueInCm
            }
        )
    }
    
    var valueInFeet: Double {
        HeightUnit.cm.convert(valueInCm, to: .ft)
    }
    
    var feetComponent: Binding<Int> {
        Binding<Int>(
            get: { Int(valueInFeet.whole) },
            set: { newValue in
                let valueInFeet = Double(newValue) + (centimetersComponent.wrappedValue / InchesPerFoot)
                valueInCm = HeightUnit.ft.convert(valueInFeet, to: .cm)
            }
        )
    }
    
    var centimetersComponent: Binding<Double> {
        Binding<Double>(
            get: { valueInFeet.fraction * InchesPerFoot },
            set: { newValue in
                let newValue = min(newValue, InchesPerFoot-1)
                let valueInFeet = Double(feetComponent.wrappedValue) + (newValue / InchesPerFoot)
                valueInCm = HeightUnit.ft.convert(valueInFeet, to: .cm)
            }
        )
    }
}
