import SwiftUI
import PrepShared

extension HealthForm {
    var sexSection: some View {

        var pickerContent: some View {
            HStack {
                Spacer()
                MenuPicker<Sex>($model.sexValue)
            }
        }
        
        var healthContent: some View {
            var foregroundColor: Color {
                if model.sexValue != nil, model.sexValue != .notSpecified {
                    Color(.secondaryLabel)
                } else {
                    Color(.tertiaryLabel)
                }
            }
            
            var string: String {
                model.sexValue?.name ?? "Unavilable"
            }
            
            return HStack {
                Spacer()
                Text(string)
                    .foregroundStyle(foregroundColor)
            }
        }
        
        var footer: some View {
            
            var string: String? {
                switch model.sexSource {
                case .healthKit:
                    switch model.health.sex?.value {
                    case .none:
                        healthFooterString(for: .sex, hasQuantity: false)
                    case .female, .male:
                        healthFooterString(for: .sex, hasQuantity: true)
                    case .notSpecified:
                        "Your sex is specified as 'Other' in the Health app, but either Male or Female is required for biological sex based equations."
                    }
                case .userEntered:
                    nil
                }
            }
            
            return Group {
                if let string {
                    Text(string)
                }
            }
        }
        
        return Section(
            header: Text("Biological Sex"),
            footer: footer
        ) {
            HealthSourcePicker(sourceBinding: $model.sexSource)
            switch model.sexSource {
            case .healthKit:       healthContent
            case .userEntered:  pickerContent
            }
        }
    }
}
