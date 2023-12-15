import SwiftUI
import PrepShared

struct HeightField: View {
    
    @Binding var unit: HeightUnit
    @Binding var valueInCm: Double?
    var focusedType: FocusState<HealthType?>.Binding

    @Binding var disabled: Bool
    var valueString: Binding<String?>
    var secondComponentString: Binding<String?>

    init(
        unit: Binding<HeightUnit>,
        valueInCm: Binding<Double?>,
        focusedType: FocusState<HealthType?>.Binding,
        disabled: Binding<Bool>,
        valueString: Binding<String?>,
        secondComponentString: Binding<String?>
    ) {
        _unit = unit
        _valueInCm = valueInCm
        self.focusedType = focusedType
        _disabled = disabled
        self.valueString = valueString
        self.secondComponentString = secondComponentString
    }
    
    var body: some View {
        HealthNumberField(
            unitBinding: $unit,
            valueBinding: valueInDisplayedUnit,
            valueString: valueString,
            firstComponentBinding: feetComponent,
            secondComponentBinding: centimetersComponent,
            secondComponentStringBinding: secondComponentString,
            focusedType: focusedType,
            healthType: .height
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
