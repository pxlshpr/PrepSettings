import SwiftUI
import PrepShared
import PrepSettings

extension MaintenanceForm {
    
    struct ActiveSection: View {
        @Bindable var biometricsStore: BiometricsStore
    }
}

extension MaintenanceForm.ActiveSection {
    
    var body: some View {
        Section("Active Energy") {
            BiometricSourcePicker(sourceBinding: $biometricsStore.activeEnergySource)
            content
        }
    }
    
    @ViewBuilder
    var content: some View {
        switch biometricsStore.activeEnergySource {
        case .health:           healthContent
        case .activityLevel:    activityContent
        case .userEntered:      bottomRow
        }
    }
    
    var healthContent: some View {
        
        @ViewBuilder
        var intervalField: some View {
            BiometricEnergyIntervalField(
                type: biometricsStore.activeEnergyIntervalType,
                value: $biometricsStore.activeEnergyIntervalValue,
                period: $biometricsStore.activeEnergyIntervalPeriod
            )
        }
        
        return Group {
            PickerField("Use", $biometricsStore.activeEnergyIntervalType)
            intervalField
            bottomRow
        }
    }
    
    var activityContent: some View {
        Group {
            PickerField("Activity level", $biometricsStore.activeEnergyActivityLevel)
            bottomRow
        }
    }

    var bottomRow: some View {
        BiometricEnergyValueField(
            value: $biometricsStore.biometrics.activeEnergyValue,
            energyUnit: $biometricsStore.activeEnergyUnit,
            interval: $biometricsStore.activeEnergyInterval,
            date: biometricsStore.biometrics.date,
            source: biometricsStore.activeEnergySource
        )
    }
}
