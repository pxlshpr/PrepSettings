import SwiftUI
import PrepShared

extension BiometricsForm {

    var weight: BiometricQuantity {
        biometricsStore.biometrics.weight ?? .init(source: .default)
    }
    
    var weightSection: some View {
        
        var healthValue: some View {
            CalculatedBiometricView(
                quantityBinding: $biometricsStore.biometrics.weightQuantity,
                secondComponent: biometricsStore.weightPoundsComponent,
                unitBinding: $biometricsStore.biometricsWeightUnit,
                source: biometricsStore.weightSource
            )
        }

        var manualValue: some View {
            ManualBiometricField(
                unitBinding: $biometricsStore.biometricsWeightUnit,
                valueBinding: $biometricsStore.weightValue,
                firstComponentBinding: $biometricsStore.weightStonesComponent,
                secondComponentBinding: $biometricsStore.weightPoundsComponent
            )
        }
        
        return Section(
            header: Text("Weight"),
            footer: BiometricFooter(
                source: biometricsStore.weightSource,
                type: .weight,
                hasQuantity: biometricsStore.biometrics.weightQuantity != nil
            )
        ) {
            BiometricSourcePicker(sourceBinding: $biometricsStore.weightSource)
            HStack {
                Spacer()
                switch weight.source {
                case .health:
                    healthValue
                case .userEntered:
                    manualValue
                }
            }
        }
    }
}
