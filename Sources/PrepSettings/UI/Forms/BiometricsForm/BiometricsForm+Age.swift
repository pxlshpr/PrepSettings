import SwiftUI
import PrepShared

extension BiometricsForm {
    var ageSection: some View {

        var computedContent: some View {
            
            var placeholder: String {
                switch biometricsStore.ageSource {
                case .health:
                    "Unavailable"
                case .userEnteredDateOfBirth:
                    "Choose your date of birth"
                case .userEnteredAge:
                    "Not set"
                }
            }
            
            return Group {
                if let age = biometricsStore.biometrics.age?.value {
                    Text("\(age)")
                        .font(BiometricFont)
                        .foregroundStyle(.secondary)
                } else {
                    Text(placeholder)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        
        var dateOfBirthBinding: Binding<Date> {
            Binding<Date>(
                get: {
                    biometricsStore.biometrics.ageDateOfBirth 
                    ?? Date.now.moveYearBy(-20)
                },
                set: {
                    biometricsStore.biometrics.ageDateOfBirth = $0
                }
            )
        }
        
        @ViewBuilder
        var dateOfBirthPickerField: some View {
            if biometricsStore.ageSource == .userEnteredDateOfBirth {
                HStack {
                    Text("Date of birth")
                    Spacer()
                    DatePicker(
                        "",
                        selection: dateOfBirthBinding,
                        displayedComponents: [.date]
                    )
                }
            }
        }
        
        return Section(
            header: Text("Age"),
            footer: BiometricFooter(
                source: biometricsStore.ageSource,
                type: .age,
                hasQuantity: biometricsStore.biometrics.age?.value != nil
            )
        ) {
            BiometricSourcePicker(sourceBinding: $biometricsStore.ageSource)
            dateOfBirthPickerField
            HStack {
                Spacer()
                switch biometricsStore.ageSource {
                case .health, .userEnteredDateOfBirth:
                    computedContent
                case .userEnteredAge:
                    NumberTextField(placeholder: "Required", binding: $biometricsStore.ageValue)
                }
                if biometricsStore.biometrics.age?.value != nil {
                    Text("years")
                        .foregroundStyle(Color(.tertiaryLabel))
                }
            }
        }
    }
}
