import SwiftUI
import PrepShared

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
