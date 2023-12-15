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
    let didRemoveWeight = NotificationCenter.default.publisher(for: .didRemoveWeight)

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
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(hidesBackButton)

            .toolbar { editToolbarContent }
            .toolbar { keyboardToolbarContent }

            .onReceive(didUpdateWeight, perform: model.didUpdateWeight)
            .onReceive(didRemoveWeight, perform: model.didRemoveWeight)

            .onChange(of: scenePhase, scenePhaseChanged)
            .onChange(of: focusedType, model.focusedTypeChanged)

            .onAppear(perform: appeared)
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
                    valueSection
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

    @ViewBuilder
    var weightFooter: some View {
        if let string = model.footerString {
            Text(string)
        }
    }

    var emptyContent: some View {
        
        var setButton: some View {
            Button("Set Weight") {
                withAnimation {
                    switch model.formType {
                    case .healthDetails:
                        healthModel.health.weight = .init(
                            source: .userEntered,
                            quantity: .init(value: nil)
                        )
                    default:
                        break
                    }
                }
            }
        }
        
        var notSetLabel: some View {
            Text("Not Set")
                .foregroundStyle(.secondary)
        }
        
        return Section(footer: weightFooter) {
            if healthModel.isEditing {
                setButton
            } else {
                notSetLabel
            }
        }
    }
    
    var hidesBackButton: Bool {
        healthModel.isEditingPast
    }
    
    var editToolbarContent: some ToolbarContent {
        
        var doneButton: some View {
            Button("Done") {
                withAnimation {
                    healthModel.isEditing = false
                }
            }
            .fontWeight(.semibold)
        }
        
        var editButton: some View {
            Button("Edit") {
                withAnimation {
                    healthModel.isEditing = true
                }
            }
        }
        
        var cancelButton: some View {
            Button("Cancel") {
                withAnimation {
                    healthModel.isEditing = false
                }
            }
        }
        
        return Group {
            ToolbarItem(placement: .topBarTrailing) {
                if !healthModel.isCurrent {
                    if healthModel.isEditing {
                        doneButton
                    } else {
                        editButton
                    }
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                if healthModel.isEditingPast {
                    cancelButton
                }
            }
        }
    }
    
    @ViewBuilder
    var removeSection: some View {
        if healthModel.isEditing {
            Section {
                Button("Remove Weight") {
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
//        if model.isUserEntered {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                focusTextField()
//            }
//        }
    }
    
    func scenePhaseChanged(old: ScenePhase, new: ScenePhase) {
        switch new {
        case .active:   
            Task {
                try await model.fetchHealthKitData()
            }
        default:        
            break
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
            let verb = healthModel.isCurrent ? "is" : "was"
            let string: String? = switch model.formType {
            case .healthDetails:
                model.useDailyAverage
                ? "This \(verb) the most recent date with weight data in Apple Health."
                : "This \(verb) the most recent weight data in Apple Health."
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
                .foregroundStyle(foregroundColor)
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
    
    var foregroundColor: Color {
        healthModel.isLocked ? .secondary : .primary
    }

    var dailyAverageValuesSection: some View {
        
        func row(_ quantity: Quantity) -> some View {
            HStack {
                Text(quantity.date?.shortTime ?? "")
                Spacer()
                Text("\(BodyMassUnit.kg.convert(quantity.value, to: settingsStore.bodyMassUnit).clean) \(settingsStore.bodyMassUnit.abbreviation)")
            }
        }
        
        func section(_ quantities: [Quantity]) -> some View {
            Section(footer: Text("The average of these values is being used.")) {
                ForEach(quantities, id: \.self) { quantity in
                    row(quantity)
                }
            }
        }
        
        var quantities: [Quantity]? {
            model.healthKitQuantities
        }
        
        return Group {
            if !healthModel.isLocked,
               model.shouldShowDailyAverageValuesSection,
               let quantities
            {
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
                        .foregroundStyle(healthModel.isLocked ? .secondary : .primary)
                    Spacer()
                    Toggle("", isOn: $model.useDailyAverage)
                }
                .disabled(healthModel.isLocked)
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
            
//            let binding = Binding<HealthSource>(
//                get: { model.sourceBinding.wrappedValue },
//                set: { newValue in
//                    model.sourceBinding.wrappedValue = newValue
//                }
//            )
//            
//            var disabledOptions: [HealthSource] {
//                guard model.formType != .healthDetails else { return [] }
//                return model.healthKitQuantities?.isEmpty == false ? [] : [.healthKit]
//            }

            PickerSection(model.sourceBinding, disabledOptions: model.disabledSources)
        }
        
        return Group {
            switch model.formType {
            case .adaptiveSample:   sampleSourcePicker
            default:                sourcePicker
            }
        }
    }
    
    var valueSection: some View {
        
        @ViewBuilder
        var nonSampleContent: some View {
            switch model.source {
            case .healthKit:
                if let value = model.computedValue(in: settingsStore.bodyMassUnit) {
                    LargeHealthValue(
                        value: value,
                        valueString: value.clean,
                        valueColor: foregroundColor,
                        unitString: settingsStore.bodyMassUnit.abbreviation
                    )
                } else {
                    Text("No Data")
                        .foregroundStyle(.secondary)
                }
            default:
                EmptyView()
            }
        }
        
        var sampleContent: some View {
            
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
                            valueColor: foregroundColor,
                            unitString: settingsStore.bodyMassUnit.abbreviation
                        )
                    } else {
                        Text("Not Set")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        
        @ViewBuilder
        var errorCell: some View {
            if model.shouldShowHealthKitError {
                HealthKitErrorCell(type: .weight)
            }
        }
        
        return Group {
            Section(footer: weightFooter) {
                errorCell
                switch model.formType {
                case .healthDetails, .specificDate: nonSampleContent
                case .adaptiveSample:               sampleContent
                }
            }
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
                healthType: .weight,
                disabled: Binding<Bool>(
                    get: { healthModel.isLocked },
                    set: { _ in }
                )
            )
//            .disabled(healthModel.isLocked)
        }
        
        var section: some View {
            Section {
                ZStack(alignment: .bottomTrailing) {
                    textField
//                    HStack {
//                        Spacer()
//                    }
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
}

//MARK: - Previews

let MockDate = Date(fromDateString: "2021_08_27")!

//#Preview {
//    return NavigationStack {
//        WeightForm(
//            healthModel: MockCurrentHealthModel,
//            settingsStore: .shared
//        )
//    }
//}

//#Preview {
//    return NavigationStack {
//        WeightForm(
//            sample: .init(
//                movingAverageInterval: .init(1, .week),
//                value: 93.5
//            ),
//            date: MockDate,
//            isPrevious: true,
//            healthModel: MockCurrentHealthModel,
//            settingsStore: .shared
//        )
//    }
//}

//#Preview {
//    return NavigationStack {
//        WeightForm(
//            date: MockDate,
//            value: 93.5,
//            source: .userEntered,
//            isDailyAverage: false,
//            healthModel: MockCurrentHealthModel,
//            settingsStore: .shared
//        )
//    }
//}

#Preview {
    Text("")
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
                HealthSummary(model: MockPastHealthModel)
                    .environment(SettingsStore.shared)
            }
        }
}
