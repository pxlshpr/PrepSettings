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
