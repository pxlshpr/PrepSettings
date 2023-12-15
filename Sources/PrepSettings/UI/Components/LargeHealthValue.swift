import SwiftUI

let LargeNumberFont: Font = .system(.largeTitle, design: .rounded, weight: .bold)
let LargeUnitFont: Font = .system(.body, design: .rounded, weight: .semibold)

struct LargeHealthValue: View {
    
    let value: Double
    let valueString: String
    let valueColor: Color
    let unitString: String
    
    init(
        value: Double,
        valueString: String,
        valueColor: Color = .primary,
        unitString: String
    ) {
        self.value = value
        self.valueString = valueString
        self.valueColor = valueColor
        self.unitString = unitString
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: UnitSpacing) {
            Spacer()
            Text(valueString)
                .animation(.default, value: value)
                .contentTransition(.numericText(value: value))
//                .font(.system(.largeTitle, design: .monospaced, weight: .bold))
                .font(LargeNumberFont)
                .foregroundStyle(valueColor)
            Text(unitString)
//                .font(.system(.body, design: .default, weight: .semibold))
                .font(LargeUnitFont)
                .foregroundStyle(.secondary)
        }
    }
}

import SwiftUI
import PrepShared

extension Int {
    var string: String {
        String(self)
    }
}

struct LargeBodyMassValue: View {
    
    @Binding var unit: BodyMassUnit
    @Binding var valueInKg: Double?
    let valueColor: Color

    init(
        unit: Binding<BodyMassUnit>,
        valueInKg: Binding<Double?>,
        valueColor: Color = .primary
    ) {
        _unit = unit
        _valueInKg = valueInKg
        self.valueColor = valueColor
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: UnitSpacing) {
            switch unit.hasTwoComponents {
            case true:
                Text("\(stonesComponent.wrappedValue ?? 0)")
                    .font(LargeNumberFont)
                    .foregroundStyle(valueColor)
                    .multilineTextAlignment(.trailing)
                unitView

                Text("\((poundsComponent.wrappedValue ?? 0).clean)")
                    .font(LargeNumberFont)
                    .foregroundStyle(valueColor)
                    .multilineTextAlignment(.trailing)
                
                /// only pass the isFocusedBinding to first component
                if let string = BodyMassUnit.secondaryUnit {
                    Text(string)
                        .foregroundStyle(.secondary)
                        .font(LargeUnitFont)
                }
            case false:
                Text("\((valueInDisplayedUnit.wrappedValue ?? 0).clean)")
                    .font(LargeNumberFont)
                    .foregroundStyle(valueColor)
                    .multilineTextAlignment(.trailing)
                unitView
            }
        }
    }
    
    var unitView: some View {
        Text(unit.abbreviation)
            .foregroundStyle(.secondary)
            .font(LargeUnitFont)
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
    
    var valueInStones: Double {
        BodyMassUnit.kg.convert(valueInKg ?? 0, to: .st)
    }
    
    var stonesComponent: Binding<Int?> {
        Binding<Int?>(
            get: { valueInStones.stonesComponent },
            set: { newValue in
                let newValue = newValue ?? 0
                let pounds = poundsComponent.wrappedValue ?? 0
                let valueInStones = Double(newValue) + (pounds / PoundsPerStone)
                valueInKg = BodyMassUnit.st.convert(valueInStones, to: .kg)
            }
        )
    }
    
    var poundsComponent: Binding<Double?> {
        Binding<Double?>(
            get: { valueInStones.poundsComponent },
            set: { newValue in
                let newValue = newValue ?? 0
                let stones = stonesComponent.wrappedValue ?? 0
                let value = min(newValue, PoundsPerStone-1)
                let valueInStones = Double(stones) + (value / PoundsPerStone)
                valueInKg = BodyMassUnit.st.convert(valueInStones, to: .kg)
            }
        )
    }
}

struct LargeBodyMassValueTest: View {
    @State var unit: BodyMassUnit = .st
    @State var valueInKg: Double? = 95.0
    var body: some View {
        NavigationStack {
            Form {
                LargeBodyMassValue(
                    unit: $unit,
                    valueInKg: $valueInKg
                )
            }
        }
    }
}
#Preview {
    LargeBodyMassValueTest()
}
