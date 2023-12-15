import SwiftUI
import PrepShared

struct BodyMassField: View {
    
    @Binding var unit: BodyMassUnit
    @Binding var valueInKg: Double?
    var focusedType: FocusState<HealthType?>.Binding
    var healthType: HealthType
    @Binding var disabled: Bool
    var valueString: Binding<String?>
    var secondComponentString: Binding<String?>

    init(
        unit: Binding<BodyMassUnit>,
        valueInKg: Binding<Double?>,
        focusedType: FocusState<HealthType?>.Binding,
        healthType: HealthType,
        disabled: Binding<Bool>,
        valueString: Binding<String?>,
        secondComponentString: Binding<String?>
    ) {
        _unit = unit
        _valueInKg = valueInKg
        self.focusedType = focusedType
        self.healthType = healthType
        _disabled = disabled
        self.valueString = valueString
        self.secondComponentString = secondComponentString
    }

    var body: some View {
        HealthNumberField(
            unitBinding: $unit,
            valueBinding: valueInDisplayedUnit,
            valueString: valueString,
            firstComponentBinding: stonesComponent,
            secondComponentBinding: poundsComponent,
            secondComponentStringBinding: secondComponentString,
            focusedType: focusedType,
            healthType: healthType,
            disabled: $disabled
        )
    }
    
    var valueInDisplayedUnit: Binding<Double?> {
        Binding<Double?>(
            get: {
                guard let valueInKg else { return nil }
                return BodyMassUnit.kg.convert(valueInKg, to: unit)
            },
            set: { newValue in
                guard let newValue else {
                    self.valueInKg = nil
                    return
                }
                let valueInKg = unit.convert(newValue, to: .kg)
                self.valueInKg = valueInKg
            }
        )
    }
    
    var valueInStones: Double? {
        guard let valueInKg else { return nil }
        return BodyMassUnit.kg.convert(valueInKg, to: .st)
    }
    
    var stonesComponent: Binding<Int?> {
        Binding<Int?>(
            get: {
                guard let valueInStones else { return nil }
                return Int(valueInStones.whole)
            },
            set: { newValue in
                guard let newValue, let pounds = poundsComponent.wrappedValue else {
                    valueInKg = nil
                    return
                }
                let valueInStones = Double(newValue) + (pounds / PoundsPerStone)
                valueInKg = BodyMassUnit.st.convert(valueInStones, to: .kg)
            }
        )
    }
    
    var poundsComponent: Binding<Double?> {
        Binding<Double?>(
            get: {
                guard let valueInStones else { return nil }
                return valueInStones.fraction * PoundsPerStone
            },
            set: { newValue in
                guard let newValue, let stones = stonesComponent.wrappedValue else {
                    valueInKg = nil
                    return
                }
                let value = min(newValue, PoundsPerStone-1)
                let valueInStones = Double(stones) + (value / PoundsPerStone)
                valueInKg = BodyMassUnit.st.convert(valueInStones, to: .kg)
            }
        )
    }
}
