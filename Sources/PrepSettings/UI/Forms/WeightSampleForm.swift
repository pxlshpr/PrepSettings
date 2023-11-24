import SwiftUI
import PrepShared

typealias DidSaveWeightHandler = (Double?) -> ()
struct WeightMovingAverageComponentForm: View {

    @Environment(\.dismiss) var dismiss
    
    @State var model: Model
    @Bindable var healthModel: HealthModel
    @Bindable var settingsStore: SettingsStore

    @State var requiresSaveConfirmation = false
    @State var showingSaveConfirmation = false
    
    let didSaveWeight: DidSaveWeightHandler

    init(
        value: Double?,
        date: Date,
        healthModel: HealthModel,
        settingsStore: SettingsStore,
        didSaveWeight: @escaping DidSaveWeightHandler
    ) {
        //TODO: Create a Model
        /// [x] Store the value, have a textValue too, store the initial value too
        /// [x] Store the date
        /// [x] Pass in the delegate (do this for WeightSampleForm.Model too
        /// [x] Use the delegate to show confirmation before saving
        /// [x] Have a didSave closure passed in to this and WeightSampleForm.Model too
        /// [x] When saved, set the value in the array of moving averages and recalculate the average
        /// [x] Now display the average value not letting user edit in WeightSampleForm
        /// [x] Handle the unit change by simply changing what the displayed value is, but still storing it using kilograms perhaps
        /// [ ] Revisit `setBodyMassUnit`, and consider removing it in favour of saving weight in kilograms and always converting to display to the Health.bodyMassUnit, consider renaming this to `displayBodyMassUnit`, and changing the Weight and LBM structs to clearly say `weightInKilograms` or something
        /// [ ] Also do the same thing with energy and height, changing from `heightUnit` to `displayHeightUnit`, changing from `energyUnit` to `displayEnergyUnit`, and changing `height` to `heightInCentimeters`
        /// [ ] Have it so that displayed value in forms reacts to change in healthModel.health.bodyMassUnit by converting itself
        /// [ ] Make sure we're calling the `HealthModel.setBodyMassUnit(_:whileEditing:)` when the unit changes and also revisit it and make sure we're doing the thing where we only chan
        /// [ ] When not in kilograms, save entered value after converting to kilograms
        _model = State(initialValue: Model(
            value: value,
            date: date,
            healthModel: healthModel,
            settingsStore: settingsStore
        ))
        self.healthModel = healthModel
        self.settingsStore = settingsStore
        self.didSaveWeight = didSaveWeight
    }
    
    var body: some View {
        Form {
            valueSection
            removeButton
        }
        .navigationTitle("Weight")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .task(loadRequiresSaveConfirmation)
        .confirmationDialog("", isPresented: $showingSaveConfirmation, actions: saveConfirmationActions, message: saveConfirmationMessage)
        .onChange(of: settingsStore.bodyMassUnit, model.bodyMassUnitChanged)
    }
    
    func saveConfirmationActions() -> some View {
        let primaryAction = isRemoving ? "Remove" : "Save"
        let secondaryAction = isRemoving ? "disable" : "modify"
        return Group {
            Button("\(primaryAction) weight and \(secondaryAction) goals") {
                save()
            }
        }
    }
    
    var isRemoving: Bool {
        model.value == nil
    }
    
    func saveConfirmationMessage() -> some View {
        let result = isRemoving
        ? "They will be disabled if you remove this."
        : "They will also be modified if you save this change."
        return Text("You have weight-based goals set on this day. \(result)")
    }
    
    @Sendable
    func loadRequiresSaveConfirmation() async {
        do {
            let requiresSaveConfirmation = try await healthModel.delegate.planIsWeightDependent(on: model.date)
            await MainActor.run {
                self.requiresSaveConfirmation = requiresSaveConfirmation
            }
        } catch {
            /// Handle error
        }
    }
    
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Save") {
                if requiresSaveConfirmation {
                    showingSaveConfirmation = true
                } else {
                    save()
                }
            }
            .disabled(model.isSaveDisabled)
        }
    }
    
    func save() {
        didSaveWeight(model.value)
        dismiss()
    }

    var valueSection: some View {
        Section {
            HStack {
                Text(model.date.adaptiveMaintenanceDateString)
                Spacer()
                if model.value == nil {
                    Button("Set weight") {
                        withAnimation {
                            model.value = 0
                            model.displayedValue = 0
                        }
                    }
                } else {
                    ManualHealthField(
                        unitBinding: $settingsStore.bodyMassUnit,
                        valueBinding: $model.displayedValue,
                        firstComponentBinding: $model.weightStonesComponent,
                        secondComponentBinding: $model.weightPoundsComponent
                    )
                }
            }
        }
    }
    
    
    @ViewBuilder
    var removeButton: some View {
        if model.value != nil {
            Section {
                Button("Remove") {
                    withAnimation {
                        model.value = nil
                    }
                }
            }
        }
    }
    
}

extension WeightMovingAverageComponentForm {
    @Observable class Model {
        
        let initialValue: Double?
        let initialUnit: BodyMassUnit
        let healthModel: HealthModel
        let settingsStore: SettingsStore

        var value: Double?
        var displayedValue: Double {
            didSet {
                value = displayedValue
            }
        }
        var date: Date
        
        init(value: Double?, date: Date, healthModel: HealthModel, settingsStore: SettingsStore) {
            self.initialValue = value
            self.initialUnit = settingsStore.bodyMassUnit
            self.healthModel = healthModel
            self.settingsStore = settingsStore
            self.value = value
            self.displayedValue = value ?? 0
            self.date = date
        }
    }
}

extension WeightMovingAverageComponentForm.Model {
    
    var isNotDirty: Bool {
        value == initialValue
        && initialUnit == settingsStore.bodyMassUnit
    }
    
    var isSaveDisabled: Bool {
        if isNotDirty { return true }
        guard let value else { return false }
        return value <= 0
    }
    
    func bodyMassUnitChanged(old: BodyMassUnit, new: BodyMassUnit) {
        guard let value else { return }
        let converted = old.convert(value, to: new)
        self.value = converted
        displayedValue = converted
    }
    
    var weightStonesComponent: Int {
        get { Int(displayedValue.whole) }
        set {
            let value = Double(newValue) + (weightPoundsComponent / PoundsPerStone)
            self.value = value
            displayedValue = value
        }
    }
    
    var weightPoundsComponent: Double {
        get { displayedValue.fraction * PoundsPerStone }
        set {
            let newValue = min(newValue, PoundsPerStone-1)
            let value = Double(weightStonesComponent) + (newValue / PoundsPerStone)
            self.value = value
            displayedValue = value
        }
    }
}

struct WeightSampleForm: View {
    
    @State var model: Model
    @Bindable var healthModel: HealthModel
    @Bindable var settingsStore: SettingsStore

    let didSaveWeight: DidSaveWeightHandler

    init(
        sample: MaintenanceWeightSample,
        date: Date,
        isPrevious: Bool,
        healthModel: HealthModel,
        settingsStore: SettingsStore,
        didSave: @escaping DidSaveWeightHandler
    ) {
        _model = State(initialValue: Model(sample: sample, date: date, isPrevious: isPrevious))
        self.didSaveWeight = didSave
        self.healthModel = healthModel
        self.settingsStore = settingsStore
    }
    
    var body: some View {
        Form {
            valueSection
            movingAverageSection
            movingAverageValuesSection
            removeButton
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .onChange(of: settingsStore.bodyMassUnit, model.bodyMassUnitChanged)
    }
    
    var title: String {
//        model.date.adaptiveMaintenanceDateString
//        "Weight for \(model.date.adaptiveMaintenanceDateString)"
        "\(model.isPrevious ? "Previous" : "Present") Weight"
    }
    
    @ViewBuilder
    var removeButton: some View {
        if model.value != nil {
            Section {
                Button("Remove") {
                    withAnimation {
                        model.value = nil
                    }
                }
            }
        }
    }
    
    var valueSection: some View {
        Section {
            HStack {
                Text(model.date.adaptiveMaintenanceDateString)
//                    .foregroundStyle(.secondary)
                Spacer()
                if model.isUsingMovingAverage {
                    if let value = model.value {
                        CalculatedHealthView(
                            quantityBinding: .constant(Quantity(value: value)),
                            secondComponent: 0,
                            unitBinding: $settingsStore.bodyMassUnit,
                            source: HealthSource.userEntered
                        )
                    } else {
                        Text("Not enough values")
                            .foregroundStyle(.tertiary)
                    }
                } else if model.value != nil {
                    ManualHealthField(
                        unitBinding: $settingsStore.bodyMassUnit,
                        valueBinding: $model.displayedValue,
                        firstComponentBinding: $model.weightStonesComponent,
                        secondComponentBinding: $model.weightPoundsComponent
                    )
                } else {
                    Button("Set weight") {
                        withAnimation {
                            model.value = 0
                            model.displayedValue = 0
                        }
                    }
                }
            }
        }
    }
    
    var movingAverageSection: some View {
        var footer: some View {
            Text("Using moving averages makes the calculation of your weight change less affected by fluctuations due to fluid loss, meal times, etc.")
        }
        
        var section: some View {
            Section(footer: footer) {
                HStack {
                    Toggle("Use Moving Average", isOn: model.usingMovingAverageBinding)
                }
                if model.isUsingMovingAverage {
                    HStack {
                        Spacer()
                        Text("of the past")
                        Stepper("", value: model.movingAverageIntervalValueBinding, in: model.movingAverageIntervalPeriod.range)
                            .fixedSize()
                        Text("\(model.movingAverageIntervalValue)")
                            .font(.system(.body, design: .monospaced, weight: .bold))
                            .contentTransition(.numericText(value: Double(model.movingAverageIntervalValue)))
                            .foregroundStyle(.secondary)
                        MenuPicker<HealthPeriod>([.day, .week], model.movingAverageIntervalPeriodBinding)
                    }
                }
            }
        }
        
        return Group {
            if !(model.value == nil && !model.isUsingMovingAverage) {
                section
            }
        }
    }

    var movingAverageValuesSection: some View {
        
        var footer: some View {
//            Text("The average of these values is being used.")
            EmptyView()
        }
        
        func cell(_ index: Int) -> some View {
            
            @ViewBuilder
            var valueText: some View {
                if let value = model.movingAverageValue(at: index) {
                    Text(value.cleanAmount)
                        .font(.system(.body, design: .monospaced, weight: .bold))
                        .animation(.default, value: value)
                        .contentTransition(.numericText(value: value))
                        .foregroundStyle(Color(.secondaryLabel))
                    Text(settingsStore.bodyMassUnit.abbreviation)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Not set")
                        .foregroundStyle(.tertiary)
                }
            }
            
            var date: Date {
                model.date.moveDayBy(-index)
            }
            
            var dateText: some View {
                Text(date.adaptiveMaintenanceDateString)
//                    .foregroundStyle(.secondary)
            }
            
            var label: some View {
                HStack {
                    dateText
                    Spacer()
                    valueText
                }
            }
            
            func didSaveWeight(_ weight: Double?) {
                model.saveWeight(weight, at: index)
                Task {
                    try await healthModel.delegate.updateBackendWeight(
                        for: date,
                        with: .init(value: weight),
                        source: .userEntered
                    )
                }
            }
            
            return NavigationLink {
                WeightMovingAverageComponentForm(
                    value: model.movingAverageValue(at: index),
                    date: date,
                    healthModel: healthModel,
                    settingsStore: settingsStore,
                    didSaveWeight: didSaveWeight
                )
                .environment(healthModel)
            } label: {
                label
            }
        }
        
        var header: some View {
            Text("Averaged values")
        }
        
        return Group {
            if model.isUsingMovingAverage {
                Section(header: header, footer: footer) {
                    ForEach(0...model.movingAverageNumberOfDays-1, id: \.self) { daysAgo in
                        cell(daysAgo)
                    }
                }
            }
        }
    }
    
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Save") {
                
            }
            .disabled(true)
        }
    }
}

#Preview {
    Text("")
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
                WeightSampleForm(
                    sample: .init(),
                    date: Date.now,
                    isPrevious: true,
                    healthModel: MockHealthModel,
                    settingsStore: SettingsStore.shared,
                    didSave: { value in
                        
                    }
                )
            }
        }
}

extension WeightSampleForm {
    @Observable class Model {

        let sampleBeingEdited: MaintenanceWeightSample
        var sample: MaintenanceWeightSample

        let date: Date
        var value: Double?
        var displayedValue: Double {
            didSet {
                value = displayedValue
            }
        }
        
        var isPrevious: Bool

        init(sample: MaintenanceWeightSample, date: Date, isPrevious: Bool) {
            self.sampleBeingEdited = sample
            self.sample = sample
            self.value = sample.value
            self.displayedValue = sample.value ?? 0
            self.date = date
            self.isPrevious = isPrevious
        }
    }
}

extension WeightSampleForm.Model {
    
    func bodyMassUnitChanged(old: BodyMassUnit, new: BodyMassUnit) {
        guard let value else { return }
        let converted = old.convert(value, to: new)
        self.value = converted
        displayedValue = converted
        
        withAnimation {
            if let movingAverageValues = sample.movingAverageValues {
                for (i, value) in movingAverageValues {
                    let converted = old.convert(value, to: new)
                    sample.movingAverageValues?[i] = converted
                }
            }
        }
    }
    
    var weightStonesComponent: Int {
        get { Int(displayedValue.whole) }
        set {
            let value = Double(newValue) + (weightPoundsComponent / PoundsPerStone)
            self.value = value
            displayedValue = value
        }
    }
    
    var weightPoundsComponent: Double {
        get { displayedValue.fraction * PoundsPerStone }
        set {
            let newValue = min(newValue, PoundsPerStone-1)
            let value = Double(weightStonesComponent) + (newValue / PoundsPerStone)
            self.value = value
            displayedValue = value
        }
    }
}

extension WeightSampleForm.Model {
    
    func saveWeight(_ weight: Double?, at index: Int) {
        withAnimation {
            sample.movingAverageValues?[index] = weight
            calculateAverage()
        }
    }
    
    func calculateAverage() {
        guard let values = sample.movingAverageValues, !values.isEmpty else {
            value = nil
            return
        }
        displayedValue = (values.reduce(0) { $0 + $1.value }) / Double(values.count)
    }
    
    var movingAverageNumberOfDays: Int {
        sample.movingAverageInterval?.numberOfDays ?? DefaultNumberOfDaysForMovingAverage
    }
    
    var usingMovingAverageBinding: Binding<Bool> {
        Binding<Bool>(
            get: { self.isUsingMovingAverage },
            set: { newValue in
                withAnimation {
                    switch newValue {
                    case false:
                        self.sample.movingAverageValues = nil
                    case true:
                        self.sample.movingAverageValues = [:]
                        self.calculateAverage()
                    }
                }
            }
        )
    }
    
    var movingAverageIntervalPeriodBinding: Binding<HealthPeriod> {
        Binding<HealthPeriod>(
            get: { self.movingAverageIntervalPeriod },
            set: { newValue in
                withAnimation {
                    var value = self.movingAverageIntervalValue
                    switch newValue {
                    case .day:
                        value = max(2, value)
                    default:
                        break
                    }
                    self.sample.movingAverageInterval = .init(value, newValue)
                }
            }
        )
    }
    
    var movingAverageIntervalPeriod: HealthPeriod {
        sample.movingAverageInterval?.period ?? .week
    }
    
    var movingAverageIntervalValueBinding: Binding<Int> {
        Binding<Int>(
            get: { self.movingAverageIntervalValue },
            set: { newValue in
//                guard let interval = self.sample.movingAverageInterval else { return }
                withAnimation {
                    self.sample.movingAverageInterval = .init(newValue, self.movingAverageIntervalPeriod)
                }
            }
        )
    }

    var movingAverageIntervalValue: Int {
        sample.movingAverageInterval?.value ?? 1
    }
    
    var isUsingMovingAverage: Bool {
        sample.movingAverageValues != nil
    }
    
    func movingAverageValue(at index: Int) -> Double? {
        sample.movingAverageValues?[index]
    }
}
