import SwiftUI
import PrepShared

extension BiometricsForm {

    var height: BiometricQuantity {
        biometricsStore.biometrics.height ?? .init(source: .default)
    }
    
    var heightSection: some View {

        var healthValue: some View {
            CalculatedBiometricView(
                quantityBinding: $biometricsStore.biometrics.heightQuantity,
                secondComponent: biometricsStore.heightCentimetersComponent,
                unitBinding: $biometricsStore.biometricsHeightUnit,
                source: biometricsStore.heightSource
            )
        }
        
        var manualValue: some View {
            ManualBiometricField(
                unitBinding: $biometricsStore.biometricsHeightUnit,
                valueBinding: $biometricsStore.heightValue,
                firstComponentBinding: $biometricsStore.heightFeetComponent,
                secondComponentBinding: $biometricsStore.heightCentimetersComponent
            )
        }
        
        return Section(
            header: Text("Height"),
            footer: BiometricFooter(
                source: biometricsStore.heightSource,
                type: .height,
                hasQuantity: biometricsStore.biometrics.heightQuantity != nil
            )
        ) {
            BiometricSourcePicker(sourceBinding: $biometricsStore.heightSource)
            HStack {
                Spacer()
                switch height.source {
                case .health:
                    healthValue
                case .userEntered:
                    manualValue
                }
            }
        }
    }
}
