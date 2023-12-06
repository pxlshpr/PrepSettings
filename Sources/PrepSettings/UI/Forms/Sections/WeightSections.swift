import SwiftUI
import PrepShared

/// [x] Create a type for the use of this form, being either the main Health.weight one, a Weight Sample or a Weight Data point or something?
/// [ ] When showing the weight data point thing, give the option to use average of past x interval, which should include the section with the links to the Weight Sample forms
/// [ ] When loading form, load the data from HealthKit based on the type
/// [ ] For standard use, load the latest weight data, getting all values for the day
/// [ ] For data point use, load the weight data on that day (do whatever we're doing currently)
/// [ ] For sample use, load the weight data on that day itself (all the values)
/// [ ] Make sure we're showing the values correctly
/// [ ] Make sure changes are saved in real time in the backend

enum WeightFormType {
    case healthDetails
    case adaptiveSample
    case adaptiveSampleAverageComponent
}

struct WeightSections: View {

    @Environment(\.scenePhase) var scenePhase: ScenePhase
    
    @Bindable var settingsStore: SettingsStore
    @Bindable var healthModel: HealthModel
    @State var model: Model
    var focusedType: FocusState<HealthType?>.Binding
    
    init(
        healthModel: HealthModel,
        settingsStore: SettingsStore,
        focusedType: FocusState<HealthType?>.Binding
    ) {
        self.healthModel = healthModel
        self.settingsStore = settingsStore
        self.focusedType = focusedType
        _model = State(initialValue: Model(healthModel: healthModel))
    }
    
    init(
        sample: WeightSample,
        date: Date,
        healthModel: HealthModel,
        settingsStore: SettingsStore,
        focusedType: FocusState<HealthType?>.Binding
    ) {
        self.healthModel = healthModel
        self.settingsStore = settingsStore
        self.focusedType = focusedType
        _model = State(initialValue: Model(
            sample: sample,
            date: date,
            healthModel: healthModel
        ))
    }
    
    init(
        value: Double?,
        date: Date,
        healthModel: HealthModel,
        settingsStore: SettingsStore,
        focusedType: FocusState<HealthType?>.Binding
    ) {
        self.healthModel = healthModel
        self.settingsStore = settingsStore
        self.focusedType = focusedType
        _model = State(initialValue: Model(
            value: value,
            date: date,
            healthModel: healthModel
        ))
    }
    
    var body: some View {
        content
            .onAppear(perform: appeared)
            .onChange(of: scenePhase, scenePhaseChanged)
    }
}

extension WeightSections {
    
    @ViewBuilder
    var content: some View {
        if model.isRemoved {
            emptyContent
        } else {
            Group {
                sourceSection
                dateSection
                movingAverageIntervalSection
                movingAverageValuesSection
                dailyAverageSection
                dailyAverageValuesSection
                valueSection
            }
        }
    }
    
    var emptyContent: some View {
        @ViewBuilder
        var footer: some View {
            if let string = model.footerString {
                Text(string)
            }
        }
        
        return Section(footer: footer) {
            Button("Set Weight") {
                withAnimation {
                    healthModel.add(.weight)
                }
            }
        }
    }
    
    func appeared() {
        model.fetchValues()
    }
    
    func scenePhaseChanged(old: ScenePhase, new: ScenePhase) {
        switch new {
        case .active:   model.fetchValues()
        default:        break
        }
    }
    
    var movingAverageIntervalSection: some View {
        
        var shouldShow: Bool {
            model.formType == .adaptiveSample &&
            model.sampleSource == .movingAverage
        }
        
        var stepper: some View {
            Stepper(
                "",
                value: $model.movingAverageIntervalValue,
                in: model.movingAverageIntervalPeriod.range
            )
        }
        
        var value: some View {
            Text("\(model.movingAverageIntervalValue)")
                .font(NumberFont)
                .contentTransition(.numericText(value: Double(model.movingAverageIntervalValue)))
        }
        
        var section: some View {
            Section("Moving Average Over") {
                HStack {
                    stepper
                        .fixedSize()
                    Spacer()
                    value
                }
                PickerSection([.day, .week], $model.movingAverageIntervalPeriod)
            }
        }
        
        return Group {
            if shouldShow {
                section
            }
        }
    }
    
    var periodSection: some View {
        PickerSection([.day, .week], $model.movingAverageIntervalPeriod)
    }
    
    var dateSection: some View {
        var footer: some View {
            let string = model.useDailyAverage
            ? "This is the most recent date with weight data in Apple Health."
            : "This is the most recent weight data in Apple Health."
            return Text(string)
        }
        
        func section(_ date: Date) -> some View {
            Section(footer: footer) {
                HStack {
                    Text("Date")
                    Spacer()
                    Text(model.useDailyAverage ? date.healthDateFormat : date.healthFormat)
                        .foregroundStyle(.secondary)
                }
            }
        }
        
        var latestQuantityDate: Date? {
            model.healthKitLatestQuantity?.date
        }
        
        return Group {
            if model.shouldShowDate, let latestQuantityDate {
                section(latestQuantityDate)
            }
        }
    }
    
    var dailyAverageValuesSection: some View {
        func section(_ quantities: [Quantity]) -> some View {
            Section(footer: Text("The average of these values is being used")) {
                ForEach(quantities, id: \.self) { quantity in
                    HStack {
                        Text(quantity.date?.shortTime ?? "")
                        Spacer()
                        Text("\(BodyMassUnit.kg.convert(quantity.value, to: settingsStore.bodyMassUnit).clean) \(settingsStore.bodyMassUnit.abbreviation)")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        
        var quantities: [Quantity]? {
            model.healthKitLatestDayQuantities
        }
        
        return Group {
            if model.shouldShowDailyAverageValuesSection, let quantities {
                section(quantities)
            }
        }
    }
    
//    var movingAverageSection: some View {
//        var footer: some View {
//            Text("Use a moving average across multiple days to get a more accurate weight that is less affected by fluctuations due to factors like fluid loss and meal times")
//        }
//
//        var section: some View {
//            Section(footer: footer) {
//                HStack {
//                    Toggle("Use Moving Average", isOn: .constant(false))
//                }
//            }
//        }
//        
//        var shouldShow: Bool {
//            model.formType == .adaptiveSample
//        }
//        return Group {
//            if shouldShow {
//                section
//            }
//        }
//    }
    
    var movingAverageValuesSection: some View {
        var shouldShow: Bool {
            model.formType == .adaptiveSample
            && model.sampleSource == .movingAverage
        }
        
        func cell(weight: DatedWeight) -> some View {
            NavigationLink(value: weight) {
                WeightCell(weight: weight)
                    .environment(settingsStore)
            }
            .navigationDestination(for: DatedWeight.self) { weight in
                WeightAveragedSampleForm(
                    value: weight.value,
                    date: weight.date,
                    healthModel: healthModel,
                    settingsStore: settingsStore,
                    didSaveWeight: { _ in
                        
                    }
                )
                .environment(healthModel)
            }
        }

        return Group {
            if shouldShow {
                Section {
                    ForEach(0...model.movingAverageNumberOfDays-1, id: \.self) {
                        cell(weight: DatedWeight(
                            value: model.movingAverageValue(at: $0),
                            date: model.date.moveDayBy(-$0)
                        ))
                    }
                }
            }
        }
    }
    
    var dailyAverageSection: some View {
        var section: some View {
            Section(footer: Text("Use the average when multiple values for the day are available.")) {
                HStack {
                    Text("Use Daily Average")
                        .layoutPriority(1)
                    Spacer()
                    Toggle("", isOn: $model.useDailyAverage)
                }
            }
        }
        
        return Group {
            if model.shouldShowDailyAverageSection {
                section
            }
        }
    }
    
    @ViewBuilder
    var sourceSection: some View {
        switch model.formType {
        case .adaptiveSample:
            PickerSection(model.sampleSourceBinding)
        default:
            PickerSection(model.sourceBinding)
        }
    }
    
    var valueSection: some View {
        
        @ViewBuilder
        var weightText: some View {
            switch model.formType {
            case .healthDetails:
                if let weight = healthModel.health.weight {
                    switch weight.source {
                    case .healthKit:
                        if let value = model.computedValue(in: settingsStore.bodyMassUnit) {
                            LargeHealthValue(
                                value: value,
                                valueString: value.clean,
                                unitString: settingsStore.bodyMassUnit.abbreviation
                            )
                            .foregroundStyle(.secondary)
                        } else {
                            Text("No data")
                                .foregroundStyle(.tertiary)
                        }
                    case .userEntered:
                        manualValue
                    }
                }
            case .adaptiveSampleAverageComponent:
                EmptyView()
            case .adaptiveSample:
                if let sampleSource = model.sampleSource {
                    switch sampleSource {
                    case .movingAverage:
                        Text("Not set")
                            .foregroundStyle(.tertiary)
                    case .healthKit:
                        Text("No data")
                            .foregroundStyle(.tertiary)
                    case .userEntered:
                        manualValue
                    }
                }
            }
        }
        
        var placeholderText: some View {
            LargeHealthValue(
                value: 0,
                valueString: "0",
                unitString: "kg"
            )
            .foregroundStyle(.secondary)
            .opacity(0)
        }
        
        return Section {
            ZStack {
                HStack {
                    Spacer()
                    weightText
                }
                placeholderText
            }
        }
    }

    var healthValue: some View {
        CalculatedBodyMassView(
            unit: $settingsStore.bodyMassUnit,
            quantityInKg: $healthModel.health.weightQuantity,
            source: healthModel.weightSource
        )
    }
     
    var manualValue: some View {
        BodyMassField(
            unit: $settingsStore.bodyMassUnit,
            valueInKg: $healthModel.weightValue,
            focusedType: focusedType,
            healthType: .weight
        )
    }
    
    //MARK: - Legacy

    @ViewBuilder
    var valueRow: some View {
        if let weight = healthModel.health.weight {
            HStack {
                Spacer()
                if healthModel.isSettingTypeFromHealthKit(.weight) {
                    ProgressView()
                } else {
                    switch weight.source {
                    case .healthKit:
                        healthValue
                    case .userEntered:
                        manualValue
                    }
                }
            }
        }
    }
    var body_ : some View {
        Section(footer: footer) {
            HealthTopRow(type: .weight, model: healthModel)
            valueRow
            healthKitErrorCell
        }
    }
    
    var footer: some View {
        HealthFooter(
            source: healthModel.weightSource,
            type: .weight,
            hasQuantity: healthModel.health.weightQuantity != nil
        )
    }
    
    @ViewBuilder
    var healthKitErrorCell: some View {
        if healthModel.shouldShowHealthKitError(for: .weight) {
            HealthKitErrorCell(type: .weight)
        }
    }
}

#Preview {
    @FocusState var focusedType: HealthType?
    return NavigationStack {
        Form {
            WeightSections(
                healthModel: MockHealthModel,
                settingsStore: .shared,
                focusedType: $focusedType
            )
        }
        .navigationTitle("Weight")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    @FocusState var focusedType: HealthType?
    return NavigationStack {
        Form {
            WeightSections(
                sample: .init(
                    movingAverageInterval: .init(1, .week),
                    movingAverageValues: [
                        1: 93,
                        5: 94
                    ],
                    value: 93.5
                ),
                date: Date(fromDateString: "2021_08_28")!,
                healthModel: MockHealthModel,
                settingsStore: .shared,
                focusedType: $focusedType
            )
        }
        .navigationTitle("Weight Sample")
        .navigationBarTitleDisplayMode(.inline)
    }
}
