import SwiftUI
import PrepShared
import PrepSettings

extension BiometricsForm {
    
    var leanBodyMass: Biometrics.LeanBodyMass {
        biometricsStore.biometrics.leanBodyMass ?? .init(source: .default)
    }

    var leanBodyMassSection: some View {
        
        var manualValue: some View {
            ManualBiometricField(
                unitBinding: $biometricsStore.biometricsLeanBodyMassUnit,
                valueBinding: $biometricsStore.leanBodyMassValue,
                firstComponentBinding: $biometricsStore.leanBodyMassStonesComponent,
                secondComponentBinding: $biometricsStore.leanBodyMassPoundsComponent
            )
        }

        var calculatedValue: some View {
            CalculatedBiometricView(
                quantityBinding: $biometricsStore.biometrics.leanBodyMassQuantity,
                secondComponent: biometricsStore.leanBodyMassPoundsComponent,
                unitBinding: $biometricsStore.biometricsLeanBodyMassUnit,
                source: biometricsStore.leanBodyMassSource
            )
        }
        
        @ViewBuilder
        var equationPicker: some View {
            if leanBodyMass.source == .equation {
                PickerField("Equation", $biometricsStore.leanBodyMassEquation)
            }
        }
        
        @ViewBuilder
        var fatPercentageField: some View {
            if leanBodyMass.source == .fatPercentage {
                HStack {
                    Text("Fat Percentage")
                    Spacer()
                    NumberTextField(
                        placeholder: "Required",
                        roundUp: true,
                        binding: $biometricsStore.fatPercentageValue
                    )
                    Text("%")
                        .foregroundStyle(Color(.tertiaryLabel))
                }
            }
        }
        
        @ViewBuilder
        var biometricsLink: some View {
            if leanBodyMass.source.isCalculated {
                NavigationLink {
                    BiometricsForm(biometricsStore, leanBodyMass.source.params)
                } label: {
                    HStack(alignment: .firstTextBaseline) {
                        Text(biometricsStore.leanBodyMassBiometricsLinkTitle)
                        Spacer()
                        biometricsStore.biometrics.leanBodyMassBiometricsLinkText
                    }
                }
            }
        }

        var valueField: some View {
            HStack {
                Spacer()
                switch leanBodyMass.source {
                case .health, .equation, .fatPercentage:
                    calculatedValue
                case .userEntered:
                    manualValue
                }
            }
        }
        
        return Section(
            header: Text("Lean Body Mass"),
            footer: BiometricFooter(
                source: biometricsStore.leanBodyMassSource,
                type: .leanBodyMass,
                hasQuantity: biometricsStore.biometrics.leanBodyMassQuantity != nil
            )
        ) {
            BiometricSourcePicker(sourceBinding: $biometricsStore.leanBodyMassSource)
            equationPicker
            biometricsLink
            fatPercentageField
            valueField
        }
    }
}
