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
        intervalPeriodSection
        valueSection
    }
    
    var sourceSection: some View {
        Section {
            ForEach(RestingEnergySource.allCases, id: \.self) { source in
                Button {
                    model.restingEnergySource = source
                } label: {
                    HStack {
                        Image(systemName: "checkmark")
                            .opacity(model.restingEnergySource == source ? 1 : 0)
                        Text(source.menuTitle)
                            .foregroundStyle(Color(.label))
                        Spacer()
                    }
                }
            }
        }
    }
    
    var valueSection: some View {
        Group {
            Section {
                intervalRow
            }
            Section {
                valueRow
            }
        }
    }
    
    var equationSection: some View {
        
        var section: some View {
            Section("Equation") {
                ForEach(RestingEnergyEquation.inOrderOfYear, id: \.self) { equation in
                    Button {
                        model.restingEnergyEquation = equation
                    } label: {
                        HStack {
                            Image(systemName: "checkmark")
                                .opacity(model.restingEnergyEquation == equation ? 1 : 0)
                            Text(equation.name)
                                .foregroundStyle(Color(.label))
                            Spacer()
                            Text(equation.year)
                                .foregroundStyle(Color(.secondaryLabel))
                        }
                    }
                }
            }
        }
        
        return Group {
            if model.restingEnergySource == .equation {
                section
            }
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

    var intervalTypeSection: some View {
        
        var section: some View {
            Section("Apple Health") {
                ForEach(HealthIntervalType.allCases, id: \.self) { type in
                    Button {
                        model.restingEnergyIntervalType = type
                    } label: {
                        HStack {
                            Image(systemName: "checkmark")
                                .opacity(type == model.restingEnergyIntervalType ? 1 : 0)
                            VStack(alignment: .leading) {
                                Text(type.menuTitle)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color(.label))
                                Text(type.detail)
                                    .font(.subheadline)
                                    .foregroundStyle(Color(.secondaryLabel))
                            }
                            Spacer()
                        }
                    }
                }
            }
        }
        
        return Group {
            if model.restingEnergySource == .healthKit {
                section
            }
        }
    }
    
    var intervalPeriodSection: some View {
        
        var section: some View {
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
            
            var picker: some View {
                MenuPicker<HealthPeriod>($model.restingEnergyIntervalPeriod)
            }
            
            var legacyRow: some View {
                HStack {
                    Spacer()
                    stepper
                        .fixedSize()
                    value
                    picker
                }
            }
            
            var row: some View {
                HStack {
                    stepper
                        .fixedSize()
                    Spacer()
                    value
                }
            }
            
            var periodButtons: some View {
                ForEach(HealthPeriod.allCases, id: \.self) { period in
                    Button {
                        model.restingEnergyIntervalPeriod = period
                    } label: {
                        HStack {
                            Image(systemName: "checkmark")
                                .opacity(model.restingEnergyIntervalPeriod == period ? 1 : 0)
                            Text(period.name.capitalized)
                                .foregroundStyle(Color(.label))
                            Spacer()
                        }
                    }
                }
            }
            
            return Group {
                Section("Daily average period") {
//                    legacyRow
                    row
                }
                Section {
                    periodButtons
                }
            }
        }
        
        return Group {
            if model.restingEnergySource == .healthKit,
               model.restingEnergyIntervalType == .average
            {
                section
            }
        }
    }
    
    var healthKitSection: some View {
        
        var section: some View {
            Section("Apple Health") {
                PickerField("Use", $model.restingEnergyIntervalType)
                healthKitIntervalField
            }
        }
        
        return Group {
            if model.restingEnergySource == .healthKit {
                section
            }
        }
    }
    
    var intervalRow: some View {
        
        var label: String {
            model.restingEnergyIntervalType == .average ? "Period" : "Date"
        }
        
        var detail: String {
            guard let interval = model.restingEnergyInterval else { return "" }
            return switch model.restingEnergyIntervalType {
            case .average:      interval.dateRange(with: model.health.date).string
            case .sameDay:      model.health.date.healthFormat
            case .previousDay:  model.health.date.moveDayBy(-1).healthFormat
            }
        }
        
        return Group {
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
    
    var valueRow: some View {
        
        @ViewBuilder
        var calculatedValue: some View {
            if let value = model.health.restingEnergyValue(in: settingsStore.energyUnit) {
//                Text("\(value.formattedEnergy) \(settingsStore.energyUnit.abbreviation)")
                HStack(alignment: .firstTextBaseline, spacing: UnitSpacing) {
                    Image(systemName: "equal")
                        .foregroundStyle(.secondary)
                        .font(.title2)
                        .fontWeight(.heavy)
                    Spacer()
                    Text(value.formattedEnergy)
                        .animation(.default, value: value)
                        .contentTransition(.numericText(value: value))
                        .font(.system(.largeTitle, design: .monospaced, weight: .bold))
                        .foregroundStyle(.primary)
                    Text(settingsStore.energyUnit.abbreviation)
                        .foregroundStyle(.primary)
                        .font(.system(.body, design: .default, weight: .semibold))
                }

            }
//            CalculatedEnergyView(
//                valueBinding: $model.health.restingEnergyValue,
////                unitBinding: $model.health.energyUnit,
//                unitBinding: $settingsStore.energyUnit,
//                intervalBinding: $model.restingEnergyInterval,
//                date: model.health.date,
//                source: model.restingEnergySource
//            )
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
        
        return HStack {
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
    
    var healthKitIntervalField: some View {
        HealthEnergyIntervalField(
            type: model.restingEnergyIntervalType,
            value: $model.restingEnergyIntervalValue,
            period: $model.restingEnergyIntervalPeriod
        )
    }
    

    //MARK: - Legacy
    var body_: some View {
        Section(footer: footer) {
            HealthTopRow(type: .restingEnergy, model: model)
            content
        }
    }
    
    var footer: some View {
        Text(HealthType.restingEnergy.reason!)
    }

    @ViewBuilder
    var content: some View {
        switch model.restingEnergySource {
        case .healthKit:    healthContent
        case .equation:     equationContent
        case .userEntered:  valueRow
        }
    }
    
    var healthContent: some View {
        
        return Group {
            PickerField("Use", $model.restingEnergyIntervalType)
            healthKitIntervalField
            valueRow
        }
    }

    enum Route {
        case params
    }
    
    var equationContent: some View {
        var healthLink: some View {
            var params: [HealthType] {
                model.restingEnergyEquation.params
            }
            
            var title: String {
                if params.count == 1, let param = params.first {
                    param.name
                } else {
                    "Health Details"
                }
            }
            
            return NavigationLink(value: Route.params) {
                HStack(alignment: .firstTextBaseline) {
                    Text(title)
                    Spacer()
                    HealthTexts(model.health, settingsStore).restingEnergyHealthLinkText
                }
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .params:
                    HealthForm(model)
                        .environment(settingsStore)
                }
            }
        }
        
        return Group {
            PickerField("Equation", $model.restingEnergyEquation)
            healthLink
            valueRow
            healthKitErrorCell
        }
    }
    
    @ViewBuilder
    var healthKitErrorCell: some View {
        if model.shouldShowHealthKitError(for: .restingEnergy) {
            HealthKitErrorCell(type: .restingEnergy)
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
