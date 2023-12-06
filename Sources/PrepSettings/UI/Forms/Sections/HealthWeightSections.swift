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
        sourceSection
        dateSection
//        movingAverageSection
        movingAverageIntervalSection
        movingAverageValuesSection
        averageSection
        averageEntriesSection
        valueSection
    }
}

extension HealthWeightSections {
    
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
//                    Text("Yesterday, 9:08 pm")
//                    Text("Yesterday's Average")
                    Text("1 Dec 2021")
//                    Text("1 Dec 2021, 9:08 pm")
                        .foregroundStyle(.secondary)
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
        var section: some View {
            Section(footer: Text("The average of these values is being used")) {
                HStack {
                    Text("9:53 am")
                    Spacer()
                    Text("95.7 kg")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("2:32 pm")
                    Spacer()
                    Text("96.3 kg")
                        .foregroundStyle(.secondary)
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
        
        return Group {
            if shouldShow {
                section
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
        var valueRow: some View {
            HStack {
//                Text("Weight")
                Spacer()
                switch model.formType {
                case .healthDetails, .adaptiveSampleAverageComponent:
                    if let weight = healthModel.health.weight {
                        switch weight.source {
                        case .healthKit:
    //                        Text("95.7 kg")
                            Text("95.4 kg")
                                .foregroundStyle(.secondary)
    //                        healthValue
                        case .userEntered:
                            manualValue
                        }
                    }
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
        }
        
        var averagedEntriesRow: some View {
            HStack {
                Text("Averaged Entries")
                Spacer()
                Text("3")
                    .foregroundStyle(.secondary)
            }
        }
        
        return Section {
//            dateRow
            valueRow
//            averagedEntriesRow
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
                    self.healthModel.weightSource = newValue
                case .adaptiveSampleAverageComponent:
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
                    break
                }
            }
        )
    }
    
    var sampleSourceBinding: Binding<WeightSampleSource> {
        Binding<WeightSampleSource>(
            get: { self.sampleSource ?? .userEntered },
            set: { newValue in
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
