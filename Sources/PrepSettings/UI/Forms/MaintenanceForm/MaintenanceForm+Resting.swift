import SwiftUI
import HealthKit
import PrepShared
import PrepSettings

extension MaintenanceForm {
    
    struct RestingSection: View {
        @Bindable var biometricsStore: BiometricsStore
    }
}

extension MaintenanceForm.RestingSection {
    
    var body: some View {
        Section("Resting Energy") {
            BiometricSourcePicker(sourceBinding: $biometricsStore.restingEnergySource)
            content
        }
    }
    
    @ViewBuilder
    var content: some View {
        switch biometricsStore.restingEnergySource {
        case .health:       healthContent
        case .equation:     equationContent
        case .userEntered:  bottomRow
        }
    }
    
    var healthContent: some View {
        
        @ViewBuilder
        var intervalField: some View {
            BiometricEnergyIntervalField(
                type: biometricsStore.restingEnergyIntervalType,
                value: $biometricsStore.restingEnergyIntervalValue,
                period: $biometricsStore.restingEnergyIntervalPeriod
            )
        }
        
        return Group {
            PickerField("Use", $biometricsStore.restingEnergyIntervalType)
            intervalField
            bottomRow
        }
    }

    var equationContent: some View {
        var biometricsLink: some View {
            var params: [BiometricType] {
                biometricsStore.restingEnergyEquation.params
            }
            
            var title: String {
                if params.count == 1, let param = params.first {
                    param.name
                } else {
                    "Health Data"
                }
            }
            
            return NavigationLink {
                BiometricsForm(biometricsStore)
            } label: {
                HStack(alignment: .firstTextBaseline) {
                    Text(title)
                    Spacer()
                    biometricsStore.biometrics.restingEnergyBiometricsLinkText
                }
            }
        }
        
        return Group {
            PickerField("Equation", $biometricsStore.restingEnergyEquation)
            biometricsLink
            bottomRow
        }
    }
    
    var bottomRow: some View {
        BiometricEnergyValueField(
            value: $biometricsStore.biometrics.restingEnergyValue,
            energyUnit: $biometricsStore.restingEnergyUnit,
            interval: $biometricsStore.restingEnergyInterval,
            date: biometricsStore.biometrics.date,
            source: biometricsStore.restingEnergySource
        )
    }
}
