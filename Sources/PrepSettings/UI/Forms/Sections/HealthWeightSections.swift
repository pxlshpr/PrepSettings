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

struct HealthWeightSections: View {

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
        Group {
            sourceSection
            dateSection
            movingAverageIntervalSection
            movingAverageValuesSection
            averageSection
            averageEntriesSection
            valueSection
        }
        .onAppear(perform: appeared)
        .onChange(of: scenePhase, scenePhaseChanged)
    }
}

extension HealthWeightSections {
    
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
            Text("This is the most recent date with weight data in Apple Health.")
        }
        
        var section: some View {
            Section(footer: footer) {
                HStack {
                    Text("Date")
                    Spacer()
                    if let date = healthModel.health.weight?.quantity?.date {
                        Text(date.healthFormat)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        
        var shouldShow: Bool {
            model.formType == .healthDetails
        }
        
        return Group {
            if shouldShow {
                section
            }
        }
    }
    
    var averageEntriesSection: some View {
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
        
        var shouldShow: Bool {
            switch model.formType {
            case .healthDetails, .adaptiveSampleAverageComponent:
                model.source == .healthKit
            case .adaptiveSample:
                model.sampleSource == .healthKit
//                model.sample?.movingAverageValues != nil
            }
        }
        
        var quantities: [Quantity]? {
            model.healthKitLatestDayQuantities
        }
        
        return Group {
            if shouldShow, let quantities {
                section(quantities)
            }
        }
    }
    
    var movingAverageSection: some View {
        var footer: some View {
            Text("Use a moving average across multiple days to get a more accurate weight that is less affected by fluctuations due to factors like fluid loss and meal times")
        }

        var section: some View {
            Section(footer: footer) {
                HStack {
                    Toggle("Use Moving Average", isOn: .constant(false))
                }
            }
        }
        
        var shouldShow: Bool {
            model.formType == .adaptiveSample
        }
        return Group {
            if shouldShow {
                section
            }
        }
    }
    
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
    
    var averageSection: some View {
        var section: some View {
            Section(footer: Text("Use the average when multiple values for the day are available.")) {
                HStack {
                    Text("Average Day's Entries")
                        .layoutPriority(1)
                    Spacer()
                    Toggle("", isOn: .constant(true))
                }
            }
        }
        
        var shouldShow: Bool {
            switch model.formType {
            case .healthDetails, .adaptiveSampleAverageComponent:
                model.source == .healthKit
            case .adaptiveSample:
                model.sampleSource == .healthKit
            }
        }
        
        return Group {
            if shouldShow {
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
        
        return Section {
            HStack {
                Spacer()
                weightText
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

extension HealthWeightSections {
    @Observable class Model {
        
        let formType: WeightFormType
        let healthModel: HealthModel
        var date: Date
        var value: Double?

        var source: HealthSource?

        var sampleSource: WeightSampleSource?
        let initialSample: WeightSample?
        var sample: WeightSample?
        
        var healthKitLatestDayQuantities: [Quantity]?
        var healthKitValueForDate: Double?
        
        /// Health init
        init(
            healthModel: HealthModel
        ) {
            self.formType = .healthDetails
            self.healthModel = healthModel
            self.date = healthModel.health.date
            
            let weight = healthModel.health.weight
            self.value = weight?.quantity?.value
            self.source = weight?.source
            
            self.initialSample = nil
            self.sample = nil
        }
        
        /// Weight Sample init
        init(
            sample: WeightSample,
            date: Date,
            healthModel: HealthModel
        ) {
            self.formType = .adaptiveSample
            self.healthModel = healthModel
            self.date = date
            
            self.value = sample.value
            self.source = nil
//            self.sampleSource = sample.source
            self.sampleSource = .movingAverage
            
            self.initialSample = sample
            self.sample = sample
        }
        
        /// Average Component init
        init(
            value: Double?,
            date: Date,
            healthModel: HealthModel
        ) {
            self.formType = .adaptiveSample
            self.healthModel = healthModel
            self.date = date
            
            self.value = value
            self.source = .userEntered
            
            self.sampleSource = nil
            self.initialSample = nil
            self.sample = nil
        }

    }
}

extension HealthWeightSections.Model {
    
    var healthKitLatestQuantity: Quantity? {
        healthKitLatestDayQuantities?.last
    }
    
    func fetchValues() {
        Task {
            switch formType {
            case .healthDetails:
                /// [ ] Fetch the latest day's values from HealthKit
                /// [ ] Keep this stored in the model
                /// [ ] If this value exists (ie is stored), only then show the Apple Health option in source
                let healthKitValue = try await healthModel.healthKitValue(for: .weight)
                await MainActor.run {
                    self.healthKitLatestDayQuantities = healthKitValue?.quantities
                }
            case .adaptiveSampleAverageComponent:
                /// [ ] Fetch the date's value
                /// [ ] Keep this stored in the model
                /// [ ] If this value exists (ie is stored), only then show the Apple Health option
                break
            case .adaptiveSample:
                /// [ ] Fetch the date's value, along with the values for all dates within the moving average interval (if sourceType is moving average)
                /// [ ] Keep them stored in the model
                /// [ ] If the value for the date exists, only then show the Apple Health option
                break
            }
        }
    }
    
    func computedValue(in unit: BodyMassUnit) -> Double? {
        switch formType {
        case .healthDetails:
            switch source {
            case .healthKit: 
                guard let value = healthKitLatestQuantity?.value else { return nil }
                return BodyMassUnit.kg.convert(value, to: unit)
            default:
                return nil
            }

        case .adaptiveSample:
            switch sampleSource {
            case .healthKit:
                guard let value = healthKitValueForDate else { return nil }
                return BodyMassUnit.kg.convert(value, to: unit)
            case .movingAverage:
                return 69.0
            default:
                return nil
            }
            
        case .adaptiveSampleAverageComponent:
            switch source {
            case .healthKit:
                guard let value = healthKitValueForDate else { return nil }
                return BodyMassUnit.kg.convert(value, to: unit)
            default:
                return nil
            }
        }
    }
    
    var quantity: Quantity? {
        guard let value else { return nil }
        return .init(value: value, date: date)
    }
    
    var sourceBinding: Binding<HealthSource> {
        Binding<HealthSource>(
            get: { self.source ?? .userEntered },
            set: { newValue in
                self.source = newValue
                
                switch self.formType {
                case .healthDetails:
                    /// [ ] Directly set the source instead of using the binding
                    /// [ ] If we switch to HealthKit, simply use the value that we would have fetched (this option shouldn't be available otherwise)
                    /// [ ] We might have to stop syncing weight from healthKit whenever biometrics change since we're doing it in the form
                    self.healthModel.weightSource = newValue
                case .adaptiveSampleAverageComponent:
                    /// [ ] We can only set to HealthKit if there is a value available—and if we do this, change the Health details for that date only
                    /// [ ] If we switch to custom, change the average component and also the health details weight by updating the 'backend weight
                    Task {
                        if let quantity = self.quantity {
                            try await self.healthModel.delegate.updateBackendWeight(
                                for: self.date,
                                with: quantity,
                                source: newValue
                            )
                        }
                    }
                case .adaptiveSample:
                    /// Not handled here (we use `sampleBinding` instead
                    break
                }
            }
        )
    }
    
    var sampleSourceBinding: Binding<WeightSampleSource> {
        Binding<WeightSampleSource>(
            get: { self.sampleSource ?? .userEntered },
            set: { newValue in
                /// [ ] If we switch to `.movingAverage` – fetch the values for the dates from the backend (whatever value we have stored for each date)
                /// [ ] If we switch to `.healthKit` – use the values we would have fetched depending on if we're using average day's entires or not
                
                withAnimation {
                    self.sampleSource = newValue
                }
                
                // Change source for the day this pertains to
                Task {
//                    if let quantity = self.quantity {
//                        try await self.healthModel.delegate.updateBackendWeight(
//                            for: self.date,
//                            with: quantity,
//                            source: newValue
//                        )
//                    }
                }
            }
        )
    }
    
    var movingAverageIntervalPeriod: HealthPeriod {
        get { sample?.movingAverageInterval?.period ?? .default }
        set {
            guard let sample else { return }
            var interval = sample.movingAverageInterval ?? .default
            interval.period = newValue
            withAnimation {
                self.sample?.movingAverageInterval = interval
                self.sample?.movingAverageInterval?.correctIfNeeded()
            }
            /// [ ] Once changed – fetch new weights
//            Task {
//            }
        }
    }

    var movingAverageIntervalValue: Int {
        get { sample?.movingAverageInterval?.value ?? 1 }
        set {
            guard let sample else { return }
            guard newValue >= movingAverageIntervalPeriod.minValue,
                  newValue <= movingAverageIntervalPeriod.maxValue
            else { return }
            
            /// [ ] Once changed – fetch new weights
            var interval = sample.movingAverageInterval ?? .default
            interval.value = newValue
            withAnimation {
                self.sample?.movingAverageInterval = interval
            }
//            Task {
//            }
        }
    }
    
    var movingAverageNumberOfDays: Int {
        sample?.movingAverageInterval?.numberOfDays ?? DefaultNumberOfDaysForMovingAverage
    }
    
    func movingAverageValue(at index: Int) -> Double? {
        guard let value = sample?.movingAverageValues?[index] 
        else { return nil }
        return BodyMassUnit.kg.convert(value, to: SettingsStore.bodyMassUnit)
    }
}

#Preview {
    @FocusState var focusedType: HealthType?
    return NavigationStack {
        Form {
            HealthWeightSections(
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
            HealthWeightSections(
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
