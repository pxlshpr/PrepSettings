import SwiftUI
import PrepShared

struct ActiveEnergySection: View {

    @Bindable var model: HealthModel
    @Bindable var settingsStore: SettingsStore

//    @FocusState var focusedType: HealthType?
    var focusedType: FocusState<HealthType?>.Binding

    var body: some View {
        Section(footer: footer) {
            HealthTopRow(type: .activeEnergy, model: model)
            content
        }
    }
    
    var footer: some View {
        Text(HealthType.activeEnergy.reason!)
    }
    
    @ViewBuilder
    var content: some View {
        switch model.activeEnergySource {
        case .healthKit:        healthContent
        case .activityLevel:    activityContent
        case .userEntered:      valueRow
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
            valueRow
            healthKitErrorCell
        }
    }
    
    @ViewBuilder
    var healthKitErrorCell: some View {
        if model.shouldShowHealthKitError(for: .activeEnergy) {
            HealthKitErrorCell(type: .activeEnergy)
        }
    }
    
    var activityContent: some View {
        Group {
            PickerField("Activity level", $model.activeEnergyActivityLevel)
            valueRow
        }
    }

    var valueRow: some View {
        var calculatedValue: some View {
            CalculatedEnergyView(
                valueBinding: $model.health.activeEnergyValue,
                unitBinding: $settingsStore.energyUnit,
                intervalBinding: $model.activeEnergyInterval,
                date: model.health.date,
                source: model.activeEnergySource
            )
        }
        
        var manualValue: some View {
            HStack(spacing: UnitSpacing) {
                Spacer()
                NumberField(
                    placeholder: "Required",
                    roundUp: true,
                    binding: $model.health.activeEnergyValue
                )
                .focused(focusedType, equals: HealthType.activeEnergy)
                Text(settingsStore.energyUnit.abbreviation)
                    .foregroundStyle(.secondary)
            }
        }
        
        return HStack {
            Spacer()
            if model.isSettingTypeFromHealthKit(.activeEnergy) {
                ProgressView()
            } else {
                switch model.activeEnergySource.isManual {
                case true:
                    manualValue
                case false:
                    calculatedValue
                }
            }
        }
    }
}

