import SwiftUI
import PrepShared


struct CalculatedHeightView<S: GenericSource>: View {
    
    @Binding var unit: HeightUnit
    @Binding var quantityInCm: Quantity?
    let source: S

    var body: some View {
        CalculatedHealthView(
            quantityBinding: quantity,
            secondComponent: centimetersComponent,
            unitBinding: $unit,
            source: source
        )
    }
    
    var valueInDisplayedUnit: Double? {
        guard let value = quantityInCm?.value else { return nil }
        return HeightUnit.cm.convert(value, to: unit)
    }
    
    var quantity: Binding<Quantity?> {
        Binding<Quantity?>(
            get: {
                guard let valueInDisplayedUnit else { return nil }
                return Quantity(value: valueInDisplayedUnit, date: quantityInCm?.date)
            },
            set: {
                guard let newValue = $0?.value else {
                    quantityInCm = nil
                    return
                }
                let valueInCm = unit.convert(newValue, to: .cm)
                quantityInCm = Quantity(value: valueInCm, date: quantityInCm?.date)
            }
        )
    }
    
    var valueInFeet: Double {
        guard let value = quantityInCm?.value else { return 0 }
        return HeightUnit.cm.convert(value, to: .ft)
    }

    var centimetersComponent: Double {
        valueInFeet.fraction * InchesPerFoot
    }
}

struct CalculatedBodyMassView<S: GenericSource>: View {
    
    @Binding var unit: BodyMassUnit
    @Binding var quantityInKg: Quantity?
    let source: S

    var body: some View {
        CalculatedHealthView(
            quantityBinding: quantity,
            secondComponent: poundsComponent,
            unitBinding: $unit,
            source: source
        )
    }
    
    var valueInDisplayedUnit: Double? {
        guard let value = quantityInKg?.value else { return nil }
        return BodyMassUnit.kg.convert(value, to: unit)
    }
    
    var quantity: Binding<Quantity?> {
        Binding<Quantity?>(
            get: {
                guard let valueInDisplayedUnit else { return nil }
                return Quantity(value: valueInDisplayedUnit, date: quantityInKg?.date)
            },
            set: {
                guard let newValue = $0?.value else {
                    quantityInKg = nil
                    return
                }
                let valueInKg = unit.convert(newValue, to: .kg)
                quantityInKg = Quantity(value: valueInKg, date: quantityInKg?.date)
            }
        )
    }
    
    var valueInStones: Double {
        guard let value = quantityInKg?.value else { return 0 }
        return BodyMassUnit.kg.convert(value, to: .st)
    }

    var poundsComponent: Double {
        valueInStones.fraction * PoundsPerStone
    }
}

struct CalculatedHealthView<Unit: HealthUnit, S: GenericSource, Q: GenericQuantity>: View {
    
    var quantityBinding: Binding<Q?>
    let secondComponent: Double
    let unitBinding: Binding<Unit>
    let source: S

    init(
        quantityBinding: Binding<Q?>,
        secondComponent: Double = 0,
        unitBinding: Binding<Unit>,
        source: S
    ) {
        self.quantityBinding = quantityBinding
        self.secondComponent = secondComponent
        self.unitBinding = unitBinding
        self.source = source
    }

    var quantity: Q? {
        quantityBinding.wrappedValue
    }
    
    var valueBinding: Binding<Double?> {
        Binding<Double?>(
            get: {
                (hasTwoComponents
                 ? quantity?.value.whole
                 : quantity?.value
                )?.rounded(toPlaces: Unit.decimalPlaces)
            },
            set: { _ in }
        )
    }
    
    var secondComponentBinding: Binding<Double?> {
        Binding<Double?>(
            get: { secondComponent.rounded(toPlaces: 1) },
            set: { _ in}
        )
    }
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            if let prefix = quantity?.prefix {
                Text(prefix)
                    .font(.footnote)
//                    .foregroundStyle(Color(.tertiaryLabel))
                    .font(.footnote)
//                    .textCase(.lowercase)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 3)
                    .padding(.horizontal, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .foregroundStyle(Color(.tertiarySystemFill))
                    )
                    .animation(.default, value: quantity?.prefix)

            }
            HStack {
                HStack {
                    HealthKitValueView(valueBinding, source)
                    if quantity != nil {
                        /// Previously used a picker, but we've since removed it in favour of having unit changes in one place
                //        MenuPicker<Unit>(unitBinding)
                        
                        Text(unitBinding.wrappedValue.abbreviation)
                            .foregroundStyle(.secondary)
                    }
                }
                if hasTwoComponents, quantity != nil {
                    HStack {
                        HealthKitValueView(secondComponentBinding, source)
                        if let string = Unit.secondaryUnit {
                            Text(string)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }
    
    var hasTwoComponents: Bool {
        unitBinding.wrappedValue.hasTwoComponents
    }
}
