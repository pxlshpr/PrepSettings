import SwiftUI
import PrepShared

struct HealthNumberField<Unit: HealthUnit>: View {
    
    let unitBinding: Binding<Unit>
    let valueBinding: Binding<Double?>
    let firstComponentBinding: Binding<Int?>
    let secondComponentBinding: Binding<Double?>
    let focusedType: FocusState<HealthType?>.Binding
    let healthType: HealthType
    
    init(
        unitBinding: Binding<Unit>,
        valueBinding: Binding<Double?>,
        firstComponentBinding: Binding<Int?> = .constant(0),
        secondComponentBinding: Binding<Double?> = .constant(0),
        focusedType: FocusState<HealthType?>.Binding,
        healthType: HealthType
    ) {
        self.unitBinding = unitBinding
        self.valueBinding = valueBinding
        self.firstComponentBinding = firstComponentBinding
        self.secondComponentBinding = secondComponentBinding
        self.focusedType = focusedType
        self.healthType = healthType
    }
    
    var body: some View {
        HStack {
            switch unitBinding.wrappedValue.hasTwoComponents {
            case true:
                NumberField(
                    placeholder: "Required",
                    binding: firstComponentBinding
                )
                .focused(focusedType, equals: healthType)
                unitView
                NumberField(
                    placeholder: "",
                    binding: secondComponentBinding
                )
                /// only pass the isFocusedBinding to first component
                if let string = Unit.secondaryUnit {
                    Text(string)
                        .foregroundStyle(.secondary)
                }
            case false:
                NumberField(
                    placeholder: "Required",
                    binding: valueBinding
                )
                .focused(focusedType, equals: healthType)
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

