import SwiftUI
import PrepShared

struct ActiveEnergySections: View {

    @Bindable var model: HealthModel
    @Bindable var settingsStore: SettingsStore

//    @FocusState var focusedType: HealthType?
    var focusedType: FocusState<HealthType?>.Binding

    var body: some View {
        sourceSection
        activitySection
        intervalTypeSection
        intervalPeriodSection
        intervalSection
        healthKitErrorSection
        valueSection
    }
    
    var sourceSection: some View {
        PickerSection($model.activeEnergySource)
    }
    
    @ViewBuilder
    var activitySection: some View {
        if model.activeEnergySource == .activityLevel {
            PickerSection($model.activeEnergyActivityLevel, "Activity Level")
        }
    }

    @ViewBuilder
    var intervalTypeSection: some View {
        if model.activeEnergySource == .healthKit {
//            PickerSection($model.activeEnergyIntervalType, "Sync")
            PickerSection($model.activeEnergyIntervalType)
        }
    }
    
    @ViewBuilder
    var intervalPeriodSection: some View {
        if model.activeEnergySource == .healthKit,
           model.activeEnergyIntervalType == .average
        {
            stepperSection
            periodSection
        }
    }
    
    var periodSection: some View {
        PickerSection($model.activeEnergyIntervalPeriod)
    }
    
    var stepperSection: some View {
        var stepper: some View {
            Stepper(
                "",
                value: $model.activeEnergyIntervalValue,
                in: model.activeEnergyIntervalPeriod.range
            )
        }
        
        var value: some View {
            Text("\(model.activeEnergyIntervalValue)")
                .font(NumberFont)
                .contentTransition(.numericText(value: Double(model.activeEnergyIntervalValue)))
        }
        
        return Section("Daily average period") {
            HStack {
                stepper
                    .fixedSize()
                Spacer()
                value
            }
        }
    }
    
    var intervalSection: some View {
        
        var label: String {
            model.activeEnergyIntervalType == .average ? "Period" : "Date"
        }
        
        var detail: String {
            guard let interval = model.activeEnergyInterval else { return "" }
            return switch model.activeEnergyIntervalType {
            case .average:      interval.dateRange(with: model.health.date).string
            case .sameDay:      model.health.date.healthDateFormat
            case .previousDay:  model.health.date.moveDayBy(-1).healthFormat
            }
        }
        
        return Section {
            if model.activeEnergySource == .healthKit {
                HStack {
                    Text(label)
                    Spacer()
                    Text(detail)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    var valueSection: some View {
        
        @ViewBuilder
        var calculatedValue: some View {
            if let value = model.health.activeEnergyValue(in: settingsStore.energyUnit) {
                LargeHealthValue(
                    value: value,
                    unitString: settingsStore.energyUnit.abbreviation
                )
            } else {
                Text(model.restingEnergySource == .healthKit ? "No data" : "Not set")
                    .foregroundStyle(.tertiary)
            }
        }

//        var calculatedValue: some View {
//            CalculatedEnergyView(
//                valueBinding: $model.health.activeEnergyValue,
//                unitBinding: $settingsStore.energyUnit,
//                intervalBinding: $model.activeEnergyInterval,
//                date: model.health.date,
//                source: model.activeEnergySource
//            )
//        }
        
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
    
    @ViewBuilder
    var healthKitErrorSection: some View {
        if model.shouldShowHealthKitError(for: .activeEnergy) {
            Section {
                HealthKitErrorCell(type: .activeEnergy)
            }
        }
    }
    
    //MARK: - Legacy

//    var body_: some View {
//        Section(footer: footer) {
//            HealthTopRow(type: .activeEnergy, model: model)
//            content
//        }
//    }
//    
//    var footer: some View {
//        Text(HealthType.activeEnergy.reason!)
//    }
//    
//    @ViewBuilder
//    var content: some View {
//        switch model.activeEnergySource {
//        case .healthKit:        healthContent
//        case .activityLevel:    activityContent
//        case .userEntered:      valueRow
//        }
//    }
//    
//    var healthContent: some View {
//        
//        @ViewBuilder
//        var intervalField: some View {
//            HealthEnergyIntervalField(
//                type: model.activeEnergyIntervalType,
//                value: $model.activeEnergyIntervalValue,
//                period: $model.activeEnergyIntervalPeriod
//            )
//        }
//        
//        return Group {
//            PickerField("Use", $model.activeEnergyIntervalType)
//            intervalField
//            valueRow
//            healthKitErrorCell
//        }
//    }
    
    
//    @ViewBuilder
//    var healthKitErrorCell: some View {
//        if model.shouldShowHealthKitError(for: .activeEnergy) {
//            HealthKitErrorCell(type: .activeEnergy)
//        }
//    }
    
//    var activityContent: some View {
//        Group {
//            PickerField("Activity level", $model.activeEnergyActivityLevel)
//            valueRow
//        }
//    }
}

#Preview {
    @FocusState var focusedType: HealthType?
    return Text("")
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
                Form {
                    ActiveEnergySections(
                        model: MockHealthModel,
                        settingsStore: SettingsStore.shared,
                        focusedType: $focusedType
                    )
                }
                .navigationTitle("Active Energy")
            }
        }
}
