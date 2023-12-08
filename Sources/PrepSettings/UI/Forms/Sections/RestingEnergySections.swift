import SwiftUI
import PrepShared

struct RestingEnergySections: View {
    
    @Bindable var model: HealthModel
    @Bindable var settingsStore: SettingsStore

    var focusedType: FocusState<HealthType?>.Binding

    var body: some View {
        sourceSection
        equationSection
        equationParamsSection
        intervalTypeSection
        intervalSections
        dateSection
        healthKitErrorSection
        valueSection
    }
    
    var sourceSection: some View {
        PickerSection($model.restingEnergySource)
    }
    
    @ViewBuilder
    var equationSection: some View {
        if model.restingEnergySource == .equation {
            PickerSection($model.restingEnergyEquation)
        }
    }
    
    var equationParamsSection: some View {
        var section: some View {
            Section("Health Details") {
                ForEach(model.restingEnergyEquation.params, id: \.self) { type in
                    HealthLink(type: type)
                        .environment(settingsStore)
                        .environment(model)
                }
            }
        }
        return Group {
            if model.restingEnergySource == .equation, !model.restingEnergyEquation.params.isEmpty {
                section
            }
        }
    }

    @ViewBuilder
    var intervalTypeSection: some View {
        if model.restingEnergySource == .healthKit {
            PickerSection($model.restingEnergyIntervalType, "Sync")
        }
    }
    
    @ViewBuilder
    var intervalSections: some View {
        if model.restingEnergySource == .healthKit,
           model.restingEnergyIntervalType == .average
        {
            stepperSection
            periodSection
        }
    }
    
    var periodSection: some View {
        PickerSection($model.restingEnergyIntervalPeriod)
    }
    
    var stepperSection: some View {
        var stepper: some View {
            Stepper(
                "",
                value: $model.restingEnergyIntervalValue,
                in: model.restingEnergyIntervalPeriod.range
            )
        }
        
        var value: some View {
            Text("\(model.restingEnergyIntervalValue)")
                .font(NumberFont)
                .contentTransition(.numericText(value: Double(model.restingEnergyIntervalValue)))
//                    .foregroundStyle(.secondary)
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
    
    var dateSection: some View {
        
        var label: String {
            model.restingEnergyIntervalType == .average ? "Period" : "Date"
        }
        
        var detail: String {
            guard let interval = model.restingEnergyInterval else { return "" }
            return switch model.restingEnergyIntervalType {
            case .average:      interval.dateRange(with: model.health.date).string
            case .sameDay:      model.health.date.healthDateFormat
            case .previousDay:  model.health.date.moveDayBy(-1).healthDateFormat
            }
        }
        
        return Section {
            if model.restingEnergySource == .healthKit {
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
            if let value = model.health.restingEnergyValue(in: settingsStore.energyUnit) {
                LargeHealthValue(
                    value: value,
                    valueString: value.formattedEnergy,
                    unitString: settingsStore.energyUnit.abbreviation
                )
            } else {
                Text(model.restingEnergySource == .healthKit ? "No Data" : "Not Set")
                    .foregroundStyle(.tertiary)
            }
        }
        
        var manualValue: some View {
            HStack(spacing: UnitSpacing) {
                Spacer()
                NumberField(
                    placeholder: "Required",
                    roundUp: true,
                    binding: $model.health.restingEnergyValue
                )
                .focused(focusedType, equals: HealthType.restingEnergy)
                Text(settingsStore.energyUnit.abbreviation)
                    .foregroundStyle(.secondary)
            }
        }
        
        return Section {
            HStack {
                Spacer()
                if model.isSettingTypeFromHealthKit(.restingEnergy) {
                    ProgressView()
                } else {
                    switch model.restingEnergySource.isManual {
                    case true:
                        manualValue
                    case false:
                        calculatedValue
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    var healthKitErrorSection: some View {
        if model.shouldShowHealthKitError(for: .restingEnergy) {
            Section {
                HealthKitErrorCell(type: .restingEnergy)
            }
        }
    }
}

#Preview {
    @FocusState var focusedType: HealthType?
    return Text("")
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
                Form {
                    RestingEnergySections(
                        model: MockHealthModel,
                        settingsStore: SettingsStore.shared,
                        focusedType: $focusedType
                    )
                }
                .navigationTitle("Resting Energy")
            }
        }
}
