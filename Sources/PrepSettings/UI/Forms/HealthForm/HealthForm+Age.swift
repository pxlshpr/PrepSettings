import SwiftUI
import PrepShared

extension HealthForm {
    var ageSection: some View {

        var computedContent: some View {
            
            var placeholder: String {
                switch model.ageSource {
                case .healthKit:
                    "Unavailable"
                case .userEnteredDateOfBirth:
                    "Choose your date of birth"
                case .userEnteredAge:
                    "Not set"
                }
            }
            
            return Group {
                if let age = model.health.age?.value {
                    Text("\(age)")
                        .font(HealthFont)
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
                    model.health.ageDateOfBirth 
                    ?? Date.now.moveYearBy(-20)
                },
                set: {
                    model.health.ageDateOfBirth = $0
                }
            )
        }
        
        @ViewBuilder
        var dateOfBirthPickerField: some View {
            if model.ageSource == .userEnteredDateOfBirth {
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
            footer: HealthFooter(
                source: model.ageSource,
                type: .age,
                hasQuantity: model.health.age?.value != nil
            )
        ) {
            HealthSourcePicker(sourceBinding: $model.ageSource)
            dateOfBirthPickerField
            HStack {
                Spacer()
                switch model.ageSource {
                case .healthKit, .userEnteredDateOfBirth:
                    computedContent
                case .userEnteredAge:
                    NumberTextField(placeholder: "Required", binding: $model.ageValue)
                }
                if model.health.age?.value != nil {
                    Text("years")
                        .foregroundStyle(Color(.tertiaryLabel))
                }
            }
        }
    }
}
