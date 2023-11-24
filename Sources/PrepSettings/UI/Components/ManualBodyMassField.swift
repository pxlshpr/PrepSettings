import SwiftUI
import PrepShared

struct ManualBodyMassField: View {
    
    @Binding var unit: BodyMassUnit
    @Binding var valueInKg: Double
    
    var body: some View {
        ManualHealthField(
            unitBinding: $unit,
            valueBinding: valueInDisplayedUnit,
            firstComponentBinding: stonesComponent,
            secondComponentBinding: poundsComponent
        )
    }
    
    var valueInDisplayedUnit: Binding<Double> {
        Binding<Double>(
            get: { BodyMassUnit.kg.convert(valueInKg, to: unit) },
            set: {
                let valueInKg = unit.convert($0, to: .kg)
                self.valueInKg = valueInKg
            }
        )
    }
    
    var valueInStones: Double {
        BodyMassUnit.kg.convert(valueInKg, to: .st)
    }
    
    var stonesComponent: Binding<Int> {
        Binding<Int>(
            get: { Int(valueInStones.whole) },
            set: { newValue in
                let valueInStones = Double(newValue) + (poundsComponent.wrappedValue / PoundsPerStone)
                valueInKg = BodyMassUnit.st.convert(valueInStones, to: .kg)
            }
        )
    }
    
    var poundsComponent: Binding<Double> {
        Binding<Double>(
            get: { valueInStones.fraction * PoundsPerStone },
            set: { newValue in
                let newValue = min(newValue, PoundsPerStone-1)
                let valueInStones = Double(stonesComponent.wrappedValue) + (newValue / PoundsPerStone)
                valueInKg = BodyMassUnit.st.convert(valueInStones, to: .kg)
            }
        )
    }
}
