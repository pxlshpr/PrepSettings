import SwiftUI
import PrepShared

typealias DidSaveWeightHandler = (Double?) -> ()
struct WeightMovingAverageComponentForm: View {

    @Environment(HealthModel.self) var healthModel
    @Environment(\.dismiss) var dismiss
    @State var model: Model
    
    @State var requiresSaveConfirmation = false
    @State var showingSaveConfirmation = false
    
    let didSaveWeight: DidSaveWeightHandler

    init(value: Double?, date: Date, didSaveWeight: @escaping DidSaveWeightHandler) {
        //TODO: Create a Model
        /// [x] Store the value, have a textValue too, store the initial value too
        /// [x] Store the date
        /// [x] Pass in the delegate (do this for WeightSampleForm.Model too
        /// [x] Use the delegate to show confirmation before saving
        /// [ ] Have a didSave closure passed in to this and WeightSampleForm.Model too
        /// [ ] When saved, set the value in the array of moving averages and recalculate the average
        /// [ ] Now display the average value not letting user edit in WeightSampleForm
        /// [ ] Handle the unit change by simply changing what the displayed value is, but still storing it using kilograms perhaps
        /// [ ] When not in kilograms, save entered value after converting to kilograms
        _model = State(initialValue: Model(value: value, date: date))
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
    }
    
    func saveConfirmationActions() -> some View {
        Group {
            Button("\(model.value == nil ? "Remove" : "Save") weight and \(model.value == nil ? "disable" : "modify") goals") {
                save()
            }
        }
    }
    
    func saveConfirmationMessage() -> some View {
        Text("You have goals on this day that are based on your weight, which will be \(model.value == nil ? "disabled" : "modified").")
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
                            model.textValue = 0
                        }
                    }
                } else {
                    ManualHealthField(
                        unitBinding: .constant(BodyMassUnit.kg),
                        valueBinding: $model.textValue,
                        firstComponentBinding: .constant(0),
                        secondComponentBinding: .constant(0)
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

        var value: Double?
        var textValue: Double {
            didSet {
                value = textValue
            }
        }
        var date: Date
        
        init(value: Double?, date: Date) {
            self.initialValue = value
            self.value = value
            self.textValue = value ?? 0
            self.date = date
        }
    }
}

extension WeightMovingAverageComponentForm.Model {
    var isSaveDisabled: Bool {
        if value == initialValue { return true }
        guard let value else { return false }
        return value <= 0
    }
}

struct WeightSampleForm: View {
    
    @Environment(HealthModel.self) var healthModel
    @State var model: Model
    
    init(sample: MaintenanceWeightSample, date: Date, isPrevious: Bool) {
        _model = State(initialValue: Model(sample: sample, date: date, isPrevious: isPrevious))
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
                    .foregroundStyle(.secondary)
                Spacer()
                if model.value == nil {
                    Button("Set weight") {
                        withAnimation {
                            model.value = 0
                            model.textValue = 0
                        }
                    }
                } else {
                    if model.isUsingMovingAverage {
                        Text("Average goes here")
                    } else {
                        ManualHealthField(
                            unitBinding: .constant(BodyMassUnit.kg),
                            valueBinding: $model.textValue,
                            firstComponentBinding: .constant(0),
                            secondComponentBinding: .constant(0)
                        )
                    }
                }
//                if model.isUsingMovingAverage {
//                    Text("Average value")
//                    CalculatedHealthView(
//                        quantityBinding: .constant(Quantity(value: 96.0, date: Date.now)),
//                        secondComponent: 0,
//                        unitBinding: .constant(BodyMassUnit.kg),
//                        source: model.type
//                    )
//                } else {
//                    Text("Manual Health Field")
//                }
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
            if model.value != nil {
                section
            }
        }
    }

    var movingAverageValuesSection: some View {
        
        var footer: some View {
            Text("The average of these values is being used.")
        }
        
        func cell(_ index: Int) -> some View {
            
            var valueText: some View {
                if let value = model.movingAverageValue(at: index) {
                    Text(value.cleanAmount)
                        .foregroundStyle(Color(.secondaryLabel))
//                        .foregroundStyle(model.type == .healthKit ? Color(.secondaryLabel) : Color(.label))
//                    Text("kg")
//                        .foregroundStyle(.secondary)
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
                    .foregroundStyle(.secondary)
            }
            
            var label: some View {
                HStack {
                    valueText
                    Spacer()
                    dateText
                }
            }
            
            func didSaveWeight(_ weight: Double?) {
                withAnimation {
                    model.sample.averagedValues?[index] = weight
                }
                Task {
                    try await healthModel.delegate.updateWeight(
                        for: date,
                        with: weight,
                        source: .userEntered
                    )
                }
            }
            
            return NavigationLink {
                WeightMovingAverageComponentForm(
                    value: model.movingAverageValue(at: index),
                    date: date,
                    didSaveWeight: didSaveWeight
                )
                .environment(healthModel)
            } label: {
                label
            }
        }
        
        var header: some View {
            Text("Kilograms")
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
                    isPrevious: true
                )
                .environment(MockHealthModel)
            }
        }
}

extension WeightSampleForm {
    @Observable class Model {

        let sampleBeingEdited: MaintenanceWeightSample
        var sample: MaintenanceWeightSample

        let date: Date
        var value: Double?
        var textValue: Double
        
        var isPrevious: Bool

        init(sample: MaintenanceWeightSample, date: Date, isPrevious: Bool) {
            self.sampleBeingEdited = sample
            self.sample = sample
            self.value = sample.value
            self.textValue = sample.value ?? 0
            self.date = date
            self.isPrevious = isPrevious
        }
    }
}

extension WeightSampleForm.Model {
    
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
                        self.sample.averagedValues = nil
                    case true:
                        self.sample.averagedValues = [:]
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
        sample.averagedValues != nil
    }
    
    func movingAverageValue(at index: Int) -> Double? {
        sample.averagedValues?[index]
    }
}
