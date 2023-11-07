import SwiftUI
import PrepShared
import PrepSettings

extension BiometricsForm {
    var sexSection: some View {

        var pickerContent: some View {
            HStack {
                Spacer()
                MenuPicker<BiometricSex>($biometricsStore.sexValue)
            }
        }
        
        var healthContent: some View {
            var foregroundColor: Color {
                if biometricsStore.sexValue != nil, biometricsStore.sexValue != .notSpecified {
                    Color(.secondaryLabel)
                } else {
                    Color(.tertiaryLabel)
                }
            }
            
            var string: String {
                biometricsStore.sexValue?.name ?? "Unavilable"
            }
            
            return HStack {
                Spacer()
                Text(string)
                    .foregroundStyle(foregroundColor)
            }
        }
        
        var footer: some View {
            
            var string: String? {
                switch biometricsStore.sexSource {
                case .health:
                    switch biometricsStore.biometrics.sex?.value {
                    case .none:
                        healthFooterString(forBiometric: .sex, hasQuantity: false)
                    case .female, .male:
                        healthFooterString(forBiometric: .sex, hasQuantity: true)
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
            BiometricSourcePicker(sourceBinding: $biometricsStore.sexSource)
            switch biometricsStore.sexSource {
            case .health:       healthContent
            case .userEntered:  pickerContent
            }
        }
    }
}
