import SwiftUI
import PrepShared
import SwiftHaptics

/// [x] Create a type for the use of this form, being either the main Health.weight one, a Weight Sample or a Weight Data point or something?
/// [ ] When showing the weight data point thing, give the option to use average of past x interval, which should include the section with the links to the Weight Sample forms
/// [ ] When loading form, load the data from HealthKit based on the type
/// [ ] For standard use, load the latest weight data, getting all values for the day
/// [ ] For data point use, load the weight data on that day (do whatever we're doing currently)
/// [ ] For sample use, load the weight data on that day itself (all the values)
/// [ ] Make sure we're showing the values correctly
/// [ ] Make sure changes are saved in real time in the backend

/// **Adaptive Sample**
/// [x] Don't show Apple Health (or disable it), if there aren't values for it
/// [ ] Link "Use Daily Average" to binding
/// [ ] Don't averaged values if "use daily average" is off
/// [ ] Any changes with Apple Health or Custom selected should be sent and saved to the backend immediately in addition to changing it in WeightChange
/// [ ] Fetch the values for the current interval too
/// [x] Use new interval picker
/// [ ] Removing value should only remove the value in Maintenance, not in backend
/// [ ] Change in custom value should be immediately saved
/// [ ] Loading form should select correct source
///

struct WeightForm: View {

    @Environment(\.scenePhase) var scenePhase: ScenePhase
    
    @Bindable var settingsStore: SettingsStore
    @Bindable var healthModel: HealthModel
    @State var model: Model
    
    @FocusState var focusedType: HealthType?

    let didUpdateWeight = NotificationCenter.default.publisher(for: .didUpdateWeight)
    
    init(
        healthModel: HealthModel,
        settingsStore: SettingsStore
    ) {
        self.healthModel = healthModel
        self.settingsStore = settingsStore
        _model = State(initialValue: Model(healthModel: healthModel))
    }
    
    init(
        sample: WeightSample,
        date: Date,
        isPrevious: Bool,
        healthModel: HealthModel,
        settingsStore: SettingsStore
    ) {
        self.healthModel = healthModel
        self.settingsStore = settingsStore
        _model = State(initialValue: Model(
            sample: sample,
            date: date,
            isPrevious: isPrevious,
            healthModel: healthModel
        ))
    }
    
    init(
        date: Date,
        value: Double?,
        source: HealthSource?,
        isDailyAverage: Bool?,
        healthModel: HealthModel,
        settingsStore: SettingsStore
    ) {
        self.healthModel = healthModel
        self.settingsStore = settingsStore
        _model = State(initialValue: Model(
            date: date,
            value: value,
            source: source,
            isDailyAverage: isDailyAverage,
            healthModel: healthModel
        ))
    }
    
    var body: some View {
        content
            .onAppear(perform: appeared)
            .onChange(of: scenePhase, scenePhaseChanged)
            .toolbar { bottomToolbarContent }

            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: focusedType, model.focusedTypeChanged)
            .toolbar { keyboardToolbarContent }
            .onReceive(didUpdateWeight, perform: model.didUpdateWeight)
    }
}

extension WeightForm {
    
    var content: some View {
        Form {
            sampleDateSection
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
                    errorSection
                    textFieldSection
                    removeSection
                }
            }
        }
    }
    
    var title: String {
        switch model.formType {
        case .adaptiveSample(let isPrevious):
            "\(isPrevious ? "Previous" : "Current") Weight"
        default:
            "Weight"
        }
    }
    
    var keyboardToolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            HStack {
                Spacer()
                Button("Done") {
                    focusedType = nil
                }
                .fontWeight(.semibold)
            }
        }
    }
    
    var bottomToolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            Spacer()
            weightText
//            adaptiveSampleValue
        }
    }
    
    @ViewBuilder
    var sampleDateSection: some View {
        switch model.formType {
        case .adaptiveSample, .specificDate:
            Section {
                HStack {
                    Text("Date")
                    Spacer()
                    Text(model.date.healthDateFormat)
                }
            }
        default:
            EmptyView()
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
                    model.setWeight()
                }
            }
        }
    }
    
    var removeSection: some View {
        Section {
            Button("Remove") {
                withAnimation {
                    model.removeWeight()
                }
            }
        }
    }
    
    func appeared() {
        Task {
            try await model.fetchHealthKitData()
            try await model.fetchBackendData()
        }
        if model.isUserEntered {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                focusTextField()
            }
        }
    }
    
    func scenePhaseChanged(old: ScenePhase, new: ScenePhase) {
        switch new {
        case .active:   
            Task {
                try await model.fetchHealthKitData()
            }
        default:        break
        }
    }
    
    var movingAverageIntervalSection: some View {
        
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
        
        let intervalBinding = Binding<HealthInterval>(
            get: {
                model.sample?.movingAverageInterval ?? .default
            },
            set: { newValue in
                withAnimation {
                    model.sample?.movingAverageInterval = newValue
                    model.setMovingAverageValue()
                }
            }
        )
        
        return Group {
            if model.shouldShowMovingAverageSections {
                IntervalPicker(
                    interval: intervalBinding,
                    periods: [.day, .week],
                    ranges: [
                        .day: 2...6,
                        .week: 1...2
                    ],
                    title: "Moving Average Over"
                )
//                section
            }
        }
    }
    
    var periodSection: some View {
        PickerSection([.day, .week], $model.movingAverageIntervalPeriod)
    }
    
    var dateSection: some View {
        var footer: some View {
            let string: String? = switch model.formType {
            case .healthDetails:
                model.useDailyAverage
                ? "This is the most recent date with weight data in Apple Health."
                : "This is the most recent weight data in Apple Health."
            default: nil
            }
            return Group {
                if let string {
                    Text(string)
                } else {
                    EmptyView()
                }
            }
        }
        
        func section(_ date: Date) -> some View {
            var dateString: String {
                switch model.formType {
                case .healthDetails:
                    model.useDailyAverage ? date.healthDateFormat : date.healthFormat
                case .specificDate:
                    date.healthTimeFormat
                default: ""
                }
            }
            
            var label: String {
                switch model.formType {
                case .healthDetails:    "Date"
                case .specificDate:     "Time"
                default: ""
                }
            }
            
            return Section(footer: footer) {
                HStack {
                    Text(label)
                    Spacer()
                    Text(dateString)
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
            Section(footer: Text("The average of these values is being used.")) {
                ForEach(quantities, id: \.self) { quantity in
                    HStack {
                        Text(quantity.date?.shortTime ?? "")
                        Spacer()
                        Text("\(BodyMassUnit.kg.convert(quantity.value, to: settingsStore.bodyMassUnit).clean) \(settingsStore.bodyMassUnit.abbreviation)")
                    }
                }
            }
        }
        
        var quantities: [Quantity]? {
            model.healthKitQuantities
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
        func cell(weight: DatedWeight) -> some View {
            NavigationLink(value: weight) {
                WeightCell(weight: weight)
                    .environment(settingsStore)
            }
            .navigationDestination(for: DatedWeight.self) { weight in
                WeightForm(
                    date: weight.date,
                    value: weight.value,
                    source: weight.source,
                    isDailyAverage: weight.isDailyAverage,
                    healthModel: healthModel,
                    settingsStore: settingsStore
                )
//                WeightAveragedSampleForm(
//                    value: weight.value,
//                    date: weight.date,
//                    healthModel: healthModel,
//                    settingsStore: settingsStore,
//                    didSaveWeight: { _ in
//                        
//                    }
//                )
            }
        }

        return Group {
            if model.shouldShowMovingAverageSections {
                Section {
                    ForEach(model.movingAverageDatedWeights, id: \.self) {
                        cell(weight: $0)
                    }
//                    ForEach(0...model.movingAverageNumberOfDays-1, id: \.self) {
//                        cell(
//                            weight: DatedWeight(
//                                date: model.date.moveDayBy(-$0),
//                                value: model.backendValue(at: $0),
//                                source: model.backendSource(at: $0),
//                                isDailyAverage: model.backendHealthQuantity(at: $0)?.isDailyAverage
//                            )
//                        )
//                    }
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
    
    func focusTextField() {
//        Haptics.selectionFeedback()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            focusedType = .weight
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                sendSelectAllTextAction()
            }
        }
    }

    func unfocusTextField() {
        focusedType = nil
    }

    var sourceSection: some View {
        
        var sampleSourcePicker: some View {
            let binding = Binding<WeightSampleSource>(
                get: { model.sampleSourceBinding.wrappedValue },
                set: { newValue in
                    model.sampleSourceBinding.wrappedValue = newValue
                    if newValue == .userEntered {
                        focusTextField()
                    } else {
                        unfocusTextField()
                    }
                }
            )
            
            var options: [WeightSampleSource] {
                if model.healthKitQuantities?.isEmpty == false {
                    WeightSampleSource.allCases
                } else {
                    [.movingAverage, .userEntered]
                }
            }

            var disabledOptions: [WeightSampleSource] {
                model.healthKitQuantities?.isEmpty == false ? [] : [.healthKit]
            }

            return PickerSection(binding, disabledOptions: disabledOptions)
        }
        
        var sourcePicker: some View {
            
            let binding = Binding<HealthSource>(
                get: { model.sourceBinding.wrappedValue },
                set: { newValue in
                    model.sourceBinding.wrappedValue = newValue
                    if newValue == .userEntered {
                        focusTextField()
                    } else {
                        unfocusTextField()
                    }
                }
            )
            
            var disabledOptions: [HealthSource] {
                guard model.formType != .healthDetails else { return [] }
                return model.healthKitQuantities?.isEmpty == false ? [] : [.healthKit]
            }

            return PickerSection(binding, disabledOptions: disabledOptions)
        }
        
        return Group {
            switch model.formType {
            case .adaptiveSample:   sampleSourcePicker
            default:                sourcePicker
            }
        }
    }
    
    var adaptiveSampleValue: some View {
        
        var sampleSource: WeightSampleSource {
            model.sampleSource ?? .default
        }
        
        var sampleValue: Double? {
            guard let value = model.sample?.value else { return nil }
            return BodyMassUnit.kg.convert(value, to: .kg)
        }
        
        return Group {
            switch sampleSource {
            case .userEntered:
                EmptyView()
            default:
                if let sampleValue {
                    LargeHealthValue(
                        value: sampleValue,
                        valueString: sampleValue.clean,
                        unitString: settingsStore.bodyMassUnit.abbreviation
                    )
                } else {
                    Text("Not Set")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    var errorSection: some View {
        var shouldShow: Bool {
            model.formType == .healthDetails
            && model.computedValue(in: settingsStore.bodyMassUnit) == nil
        }
        return Group {
            if shouldShow {
                HealthKitErrorCell(type: .weight)
            }
        }
    }
    
    @ViewBuilder
    var weightText: some View {
        switch model.formType {
        case .healthDetails, .specificDate:
//            if let weight = healthModel.health.weight {
            switch model.source {
                case .healthKit:
                    if let value = model.computedValue(in: settingsStore.bodyMassUnit) {
                        LargeHealthValue(
                            value: value,
                            valueString: value.clean,
                            unitString: settingsStore.bodyMassUnit.abbreviation
                        )
                    } else {
                        Text("No Data")
                            .foregroundStyle(.secondary)
                    }
                default:
                    EmptyView()
                }
//            }
//        case .specificDate:
//            switch model.source {
//            case .healthKit:
//                if let value = model.computedValue(in: settingsStore.bodyMassUnit) {
//                    
//                }
//            case .userEntered:
//                EmptyView()
//            }
        case .adaptiveSample:
            adaptiveSampleValue
        }
    }
    
    var textFieldSection: some View {
        
        let binding = Binding<Double?>(
            get: {
                switch model.formType {
                case .healthDetails:                    healthModel.weightValue
                case .adaptiveSample:                   model.sample?.value
                case .specificDate:   model.value
                }
            },
            set: {
                switch model.formType {
                case .healthDetails:                    
                    healthModel.weightValue = $0

                case .adaptiveSample:
                    model.setSampleValue($0)

                case .specificDate:
                    model.value = $0
                }
            }
        )
        
        var textField: some View {
            BodyMassField(
                unit: $settingsStore.bodyMassUnit,
                valueInKg: binding,
                focusedType: $focusedType,
                healthType: .weight
            )
        }
        
        var section: some View {
            Section {
                ZStack(alignment: .bottomTrailing) {
                    HStack {
                        Spacer()
                        textField
                    }
                    LargePlaceholderText
                }
            }
        }
        
        return Group {
            if model.shouldShowTextFieldSection {
                section
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
     
    //MARK: - Legacy

//    @ViewBuilder
//    var valueRow: some View {
//        if let weight = healthModel.health.weight {
//            HStack {
//                Spacer()
//                if healthModel.isSettingTypeFromHealthKit(.weight) {
//                    ProgressView()
//                } else {
//                    switch weight.source {
//                    case .healthKit:
//                        healthValue
//                    case .userEntered:
//                        textField
//                    }
//                }
//            }
//        }
//    }
//    var body_ : some View {
//        Section(footer: footer) {
//            HealthTopRow(type: .weight, model: healthModel)
//            valueRow
//            healthKitErrorCell
//        }
//    }
//    
//    var footer: some View {
//        HealthFooter(
//            source: healthModel.weightSource,
//            type: .weight,
//            hasQuantity: healthModel.health.weightQuantity != nil
//        )
//    }
//    
//    @ViewBuilder
//    var healthKitErrorCell: some View {
//        if healthModel.shouldShowHealthKitError(for: .weight) {
//            HealthKitErrorCell(type: .weight)
//        }
//    }
}

#Preview {
    return NavigationStack {
        WeightForm(
            healthModel: MockHealthModel,
            settingsStore: .shared
        )
    }
}

let MockDate = Date(fromDateString: "2021_08_27")!

#Preview {
    return NavigationStack {
        WeightForm(
            sample: .init(
                movingAverageInterval: .init(1, .week),
                value: 93.5
            ),
            date: MockDate,
            isPrevious: true,
            healthModel: MockHealthModel,
            settingsStore: .shared
        )
    }
}

#Preview {
    return NavigationStack {
        WeightForm(
            date: MockDate,
            value: 93.5,
            source: .userEntered,
            isDailyAverage: false,
            healthModel: MockHealthModel,
            settingsStore: .shared
        )
    }
}
