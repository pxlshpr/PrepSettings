import SwiftUI
import PrepShared

struct ManualHealthField<Unit: HealthUnit>: View {
    
    let unitBinding: Binding<Unit>
    let valueBinding: Binding<Double>
    let firstComponentBinding: Binding<Int>
    let secondComponentBinding: Binding<Double>
    let isFocusedBinding: Binding<Bool>?

    init(
        unitBinding: Binding<Unit>,
        valueBinding: Binding<Double>,
        firstComponentBinding: Binding<Int> = .constant(0),
        secondComponentBinding: Binding<Double> = .constant(0),
        isFocusedBinding: Binding<Bool>? = nil
    ) {
        self.unitBinding = unitBinding
        self.valueBinding = valueBinding
        self.firstComponentBinding = firstComponentBinding
        self.secondComponentBinding = secondComponentBinding
        self.isFocusedBinding = isFocusedBinding
    }
    
    var body: some View {
        HStack {
            switch unitBinding.wrappedValue.hasTwoComponents {
            case true:
                NumberTextField(
                    placeholder: "Required",
                    binding: firstComponentBinding,
                    isFocused: isFocusedBinding
                )
                unitView
                NumberTextField(
                    placeholder: "",
                    binding: secondComponentBinding
                    /// only pass the isFocusedBinding to first component
                )
                if let string = Unit.secondaryUnit {
                    Text(string)
                        .foregroundStyle(.secondary)
                }
            case false:
                NumberTextField(
                    placeholder: "Required",
                    binding: valueBinding,
                    isFocused: isFocusedBinding
                )
                unitView
            }
        }
    }
    
    var unitView: some View {
        /// Previously used a picker, but we've since removed it in favour of having unit changes in one place
//        MenuPicker<Unit>(unitBinding)
        
        Text(unitBinding.wrappedValue.abbreviation)
            .foregroundStyle(.secondary)
    }
}
