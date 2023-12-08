import SwiftUI
import PrepShared

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
