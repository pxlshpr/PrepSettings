import SwiftUI
import PrepShared

struct ManualBiometricField<Unit: BiometricUnit>: View {
    
    let unitBinding: Binding<Unit>
    let valueBinding: Binding<Double>
    let firstComponentBinding: Binding<Int>
    let secondComponentBinding: Binding<Double>

    var body: some View {
        HStack(spacing: 2) {
            switch unitBinding.wrappedValue.hasTwoComponents {
            case true:
                NumberTextField(placeholder: "Required", binding: firstComponentBinding)
                unitPicker
                NumberTextField(placeholder: "", binding: secondComponentBinding)
                if let string = Unit.secondaryUnit {
                    Text(string)
                        .foregroundStyle(.secondary)
                }
            case false:
                NumberTextField(placeholder: "Required", binding: valueBinding)
                unitPicker
            }
        }
    }
    
    var unitPicker: some View {
        MenuPicker<Unit>(unitBinding)
    }
}
