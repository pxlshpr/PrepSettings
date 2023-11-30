import SwiftUI
import PrepShared

struct ManualHealthField<Unit: HealthUnit>: View {
    
    let unitBinding: Binding<Unit>
    let valueBinding: Binding<Double>
    let firstComponentBinding: Binding<Int>
    let secondComponentBinding: Binding<Double>

    var body: some View {
        HStack(spacing: 4) {
            switch unitBinding.wrappedValue.hasTwoComponents {
            case true:
                NumberTextField(placeholder: "Required", binding: firstComponentBinding)
                unitView
                NumberTextField(placeholder: "", binding: secondComponentBinding)
                if let string = Unit.secondaryUnit {
                    Text(string)
                        .foregroundStyle(.secondary)
                }
            case false:
                NumberTextField(placeholder: "Required", binding: valueBinding)
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
