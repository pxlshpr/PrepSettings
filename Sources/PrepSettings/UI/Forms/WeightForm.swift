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

            .onChange(of: scenePhase, scenePhaseChanged)

            .onAppear(perform: appeared)
    }
}

extension WeightForm {
    
    var content: some View {
        Form {
            explanationSection
            valueSection
            //            sampleDateSection
            if model.isRemoved {
                emptyContent
            } else {
                sourceSection
                useDailyAverageSection
                dateSection
                movingAverageIntervalSection
                movingAverageValuesSection
                dailyAverageValuesSection
                removeSection
            }
        }
    }
    
    var emptyContent: some View {
        
        var setButton: some View {
            Button("Set Weight") {
                model.setWeight()
                focusTextField(afterDelay: true)
            }
        }
        
        var notSetLabel: some View {
            Text("Not Set")
                .foregroundStyle(.secondary)
        }
        
        return Section {
            if healthModel.isEditing {
                setButton
            } else {
                notSetLabel
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
}

//MARK: - Explanation

extension WeightForm {
    
    var explanationSection: some View {
        Section {
            switch model.formType {
            case .healthDetails:
                Text("Your weight is used when calculating your adaptive maintenance energy.\n\nIt may also be used in certain equations that estimate your resting energy, or when calculating your lean body mass.")
            case .adaptiveSample(let isPrevious):
                Text("This is your \(healthModel.isCurrent ? "\(isPrevious ? "previous" : "current") weight" : "weight on this date"), which is being used to calculate your weight change.\n\nUsing a moving average of multiple days smoothes out short-term fluctuations.")
            case .specificDate:
                Text("specific date explanation")
            }
            HStack {
                Text("Date")
                Spacer()
                Text(model.date.healthDateFormat)
            }
        }
    }
}

//MARK: - Toolbars

extension WeightForm {
    
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

    var editToolbarContent: some ToolbarContent {
        
        var doneButton: some View {
            Button("Done") {
                withAnimation {
                    healthModel.isEditing = false
                    model.doneEditing()
                }
            }
            .fontWeight(.semibold)
        }
        
        var editButton: some View {
            Button("Edit") {
                withAnimation {
                    healthModel.isEditing = true
                    model.startEditing()
                    if model.isUserEntered {
                        focusTextField(afterDelay: true)
                    }
                }
            }
        }
        
        var cancelButton: some View {
            Button("Cancel") {
                withAnimation {
                    healthModel.isEditing = false
                    model.cancelEditing()
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
}

//MARK: - Date Sections

extension WeightForm {

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
    
    var dateSection: some View {
        
        var footerString: String? {
            switch model.formType {
            case .healthDetails:
                if model.healthKitQuantities?.count == 1 || !model.useDailyAverage
                {
                    "This \(healthModel.isEditing ? "is" : "was") when the most recent weight in the Health App\(healthModel.isCurrent ? "" : " to this date") was logged."
                } else {
                    "This \(healthModel.isEditing ? "is" : "was") when the most recent weight in the Health App\(healthModel.isCurrent ? "" : " to this date") was logged."
                }
            default:
                nil
            }
        }
        
        @ViewBuilder
        var footer: some View {
            if let footerString {
                Text(footerString)
            } else {
                EmptyView()
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
}

//MARK: - Source

extension WeightForm {
    var sourceSection: some View {
        
        var sampleSourcePicker: some View {
            PickerSection(
                model.sampleSourceBinding,
                "Source",
                disabledOptions: model.disabledSampleSources)
        }
        
        var sourcePicker: some View {
            let binding = Binding<HealthSource>(
                get: { model.sourceBinding.wrappedValue },
                set: {
                    model.sourceBinding.wrappedValue = $0
                    focusTextField(afterDelay: true)
                }
            )
            return PickerSection(binding, "Source", disabledOptions: model.disabledSources)
        }
        
        return Group {
            switch model.formType {
            case .adaptiveSample:   sampleSourcePicker
            default:                sourcePicker
            }
        }
    }
    
}

//MARK: - Moving Average

extension WeightForm {
    
    var movingAverageIntervalSection: some View {
        
        let intervalBinding = Binding<HealthInterval>(
            get: {
                model.sampleMovingAverage?.interval ?? DefaultWeightMovingAverageInterval
            },
            set: { newValue in
                withAnimation {
                    model.sampleMovingAverage?.interval = newValue
                }
                model.setMovingAverageValue()
                model.updateSampleIfNeeded()
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
    
    var movingAverageValuesSection: some View {
        func cell(
            index: Int,
            weight: HealthDetails.Weight
        ) -> some View {
            
            let date = model.date.moveDayBy(-index)
            
            return NavigationLink(value: weight) {
                WeightCell(date: date, weight: weight)
                    .environment(settingsStore)
            }
            .navigationDestination(for: HealthDetails.Weight.self) { weight in
                WeightForm(
                    date: date,
                    value: weight.valueInKg,
                    source: weight.source,
                    isDailyAverage: weight.isDailyAverage,
                    healthModel: healthModel,
                    settingsStore: settingsStore
                )
            }
        }
        
        return Group {
            if model.shouldShowMovingAverageSections {
                Section {
                    ForEach(Array(zip(model.movingAverageWeights.indices, model.movingAverageWeights)), id: \.0) { (index, weight) in
                        cell(index: index, weight: weight)
                    }
                }
            }
        }
    }
}

//MARK: - Daily Average
extension WeightForm {
    
    var useDailyAverageSection: some View {
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
    
    var dailyAverageValuesSection: some View {
        
        func row(_ quantity: Quantity) -> some View {
            HStack {
                Text(quantity.date?.shortTime ?? "")
                Spacer()
                Text("\(BodyMassUnit.kg.convert(quantity.value, to: settingsStore.bodyMassUnit).clean) \(settingsStore.bodyMassUnit.abbreviation)")
            }
            .foregroundStyle(foregroundColor)
        }
        
        var footer: some View {
            
            let presentTense = healthModel.isEditing
            
            var multiple: String {
                let verb = presentTense ? "is being" : "was"

                let used = if model.isDailyAverage == true {
                    "The average of these \(verb) used."
                } else {
                    "The last one \(verb) being used."
                }
                
                return "These \(presentTense ? "are" : "were") the times when your weight was logged on this date. \(used)"
            }
            
            var single: String {
                let verb = presentTense ? "is" : "was"
                return "This \(verb) when your weight was logged on this date."
            }
            
            return model.healthKitQuantities?.count == 1 ? Text(single) : Text(multiple)
        }
        
        func section(_ quantities: [Quantity]) -> some View {
            Section(footer: footer) {
                ForEach(quantities, id: \.self) { quantity in
                    row(quantity)
                }
            }
        }
        
        var quantities: [Quantity]? {
            if healthModel.isLocked {
                healthModel.health.weight?.healthKitQuantities
            } else {
                model.healthKitQuantities
            }
        }
        
        return Group {
            if model.shouldShowDailyAverageValuesSection,
               let quantities
            {
                section(quantities)
            }
        }
    }
}

//MARK: - Value

extension WeightForm {
    
    var valueSection: some View {
        
        var textField: some View {
            let value = Binding<Double?>(
                get: { model.valueInKg },
                set: {
                    model.textFieldValueChanged(to: $0)
                }
            )
            
            let disabled = Binding<Bool>(
                get: { healthModel.isLocked || model.isHealthKit },
                set: { _ in }
            )
            
            var field: some View {
                BodyMassField(
                    unit: $settingsStore.bodyMassUnit,
                    valueInKg: value,
                    focusedType: $focusedType,
                    healthType: .weight,
                    disabled: disabled,
                    valueString: $model.valueString,
                    secondComponentString: $model.valueSecondComponentString
                )
            }
            
            return Group {
                if model.isUserEntered {
                    field
                }
            }
        }
        
        @ViewBuilder
        var nonSampleValue: some View {
            switch model.source {
            case .healthKit:
                if model.valueInKg != nil {
                    LargeBodyMassValue(
                        unit: $settingsStore.bodyMassUnit,
                        valueInKg: $model.valueInKg,
                        valueColor: foregroundColor
                    )
                } else {
                    Text("No Data")
                        .foregroundStyle(.secondary)
                }
            default:
                EmptyView()
            }
        }
        
        var sampleValue: some View {
            
            var sampleSource: WeightSampleSource {
                model.sampleSource ?? .default
            }
            
            return Group {
                switch sampleSource {
                case .userEntered:
                    EmptyView()
                default:
                    if model.valueInKg != nil {
                        LargeBodyMassValue(
                            unit: $settingsStore.bodyMassUnit,
                            valueInKg: $model.valueInKg,
                            valueColor: foregroundColor
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

        var section: some View {
            Section {
                errorCell
                ZStack(alignment: .trailing) {
                    switch model.formType {
                    case .healthDetails, .specificDate: nonSampleValue
                    case .adaptiveSample:               sampleValue
                    }
                    textField
                    LargePlaceholderText
                }
            }
        }
        
        return Group {
            if !model.isRemoved {
                section
            }
        }
    }
}

//MARK: - Convenience

extension WeightForm {
    
    var title: String {
        switch model.formType {
        case .adaptiveSample(let isPrevious):
            "\(isPrevious ? "Previous" : "Current") Weight"
        default:
            "Weight"
        }
    }
    
    var foregroundColor: Color {
        healthModel.isLocked ? .secondary : .primary
    }
    
    var hidesBackButton: Bool {
        healthModel.isEditingPast
    }
}

//MARK: - Actions

extension WeightForm {
    
    func appeared() {
        Task {
            try await model.fetchHealthKitData()
            //            try await model.fetchBackendData()
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
    
    func focusTextField(afterDelay: Bool = false) {
//        Haptics.selectionFeedback()
        let deadline: DispatchTime = .now() + (afterDelay ? 0.1 : 0)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            focusedType = .weight
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                sendSelectAllTextAction()
            }
        }
    }

    func unfocusTextField() {
        focusedType = nil
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
    DemoView()
}

#Preview {
    Text("")
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
                WeightForm(
                    sample: MockCurrentHealthModel.maintenance.adaptive.weightChange.current,
                    date: MockCurrentHealthModel.health.date,
                    isPrevious: false,
                    healthModel: MockCurrentHealthModel,
                    settingsStore: SettingsStore.shared
                )
                .onAppear {
                    SettingsStore.configureAsMock()
                    Task {
                        try await MockCurrentHealthModel.refresh()
                    }
                }
            }
        }
}
