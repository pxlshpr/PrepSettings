import SwiftUI
import PrepShared

//let LargeNumberFont = Font.system(.largeTitle, design: .monospaced, weight: .bold)

struct HealthNumberField<Unit: HealthUnit>: View {
    
    let unitBinding: Binding<Unit>
    let valueBinding: Binding<Double?>
    let firstComponentBinding: Binding<Int?>
    let secondComponentBinding: Binding<Double?>
    let focusedType: FocusState<HealthType?>.Binding
    let healthType: HealthType
    let disabled: Binding<Bool>?
    
    let valueString: Binding<String?>
    let secondComponentStringBinding: Binding<String?>

    init(
        unitBinding: Binding<Unit>,
        valueBinding: Binding<Double?>,
        valueString: Binding<String?>,
        firstComponentBinding: Binding<Int?> = .constant(0),
        secondComponentBinding: Binding<Double?> = .constant(0),
        secondComponentStringBinding: Binding<String?> = .constant(""),
        focusedType: FocusState<HealthType?>.Binding,
        healthType: HealthType,
        disabled: Binding<Bool>? = nil
    ) {
        self.unitBinding = unitBinding
        self.valueBinding = valueBinding
        self.valueString = valueString
        self.firstComponentBinding = firstComponentBinding
        self.secondComponentBinding = secondComponentBinding
        self.secondComponentStringBinding = secondComponentStringBinding
        self.focusedType = focusedType
        self.healthType = healthType
        self.disabled = disabled
    }
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: UnitSpacing) {
            switch unitBinding.wrappedValue.hasTwoComponents {
            case true:
                NumberField(
                    placeholder: "Required",
                    binding: firstComponentBinding,
                    font: LargeNumberFont,
                    disabled: disabled
                )
                .focused(focusedType, equals: healthType)

                unitView
                
                NumberField(
                    placeholder: "",
                    binding: secondComponentBinding,
                    stringBinding: secondComponentStringBinding,
                    font: LargeNumberFont,
                    disabled: disabled
                )
                
                /// only pass the isFocusedBinding to first component
                if let string = Unit.secondaryUnit {
                    Text(string)
                        .foregroundStyle(.secondary)
                        .font(LargeUnitFont)
                }
            case false:
                NumberField(
                    placeholder: "Required",
                    binding: valueBinding,
                    stringBinding: valueString,
                    font: LargeNumberFont,
                    disabled: disabled
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
            .font(LargeUnitFont)
    }
}

