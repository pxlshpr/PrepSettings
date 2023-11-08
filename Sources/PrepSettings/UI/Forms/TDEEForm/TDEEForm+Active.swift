import SwiftUI
import PrepShared

extension TDEEForm {
    
    struct ActiveSection: View {
        @Bindable var model: HealthModel
    }
}

extension TDEEForm.ActiveSection {
    
    var body: some View {
        Section("Active Energy") {
            HealthSourcePicker(sourceBinding: $model.activeEnergySource)
            content
        }
    }
    
    @ViewBuilder
    var content: some View {
        switch model.activeEnergySource {
        case .healthKit:           healthContent
        case .activityLevel:    activityContent
        case .userEntered:      bottomRow
        }
    }
    
    var healthContent: some View {
        
        @ViewBuilder
        var intervalField: some View {
            HealthEnergyIntervalField(
                type: model.activeEnergyIntervalType,
                value: $model.activeEnergyIntervalValue,
                period: $model.activeEnergyIntervalPeriod
            )
        }
        
        return Group {
            PickerField("Use", $model.activeEnergyIntervalType)
            intervalField
            bottomRow
        }
    }
    
    var activityContent: some View {
        Group {
            PickerField("Activity level", $model.activeEnergyActivityLevel)
            bottomRow
        }
    }

    var bottomRow: some View {
        HealthEnergyValueField(
            value: $model.health.activeEnergyValue,
            energyUnit: $model.activeEnergyUnit,
            interval: $model.activeEnergyInterval,
            date: model.health.date,
            source: model.activeEnergySource
        )
    }
}
