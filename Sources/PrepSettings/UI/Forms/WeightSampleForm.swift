import SwiftUI
import PrepShared

typealias DidSaveWeightSampleHandler = (WeightSample) -> ()
typealias DidSaveWeightHandler = (Double?) -> ()

struct WeightSampleForm: View {
    
    @Environment(\.dismiss) var dismiss

    @State var model: Model
    @Bindable var healthModel: HealthModel
    @Bindable var settingsStore: SettingsStore

    @State var requiresSaveConfirmation = false
    @State var showingSaveConfirmation = false

    let didSaveWeight: DidSaveWeightSampleHandler

    @FocusState var focusedType: HealthType?
    
    init(
        sample: WeightSample,
        date: Date,
        healthModel: HealthModel,
        settingsStore: SettingsStore,
        didSave: @escaping DidSaveWeightSampleHandler
    ) {
        _model = State(initialValue: Model(
            sample: sample,
            date: date,
            healthModel: healthModel
        ))
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
        .navigationTitle("Weight")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .task(loadRequiresSaveConfirmation)
        .confirmationDialog("", isPresented: $showingSaveConfirmation, actions: saveConfirmationActions, message: saveConfirmationMessage)
        .onChange(of: settingsStore.bodyMassUnit, model.bodyMassUnitChanged)
        .onChange(of: focusedType, healthModel.focusedTypeChanged)
        .toolbar { keyboardToolbarContent }
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

    var isRemoving: Bool {
        model.isRemoved || model.sample.value == nil
    }
    
    func saveConfirmationActions() -> some View {
        let primaryAction = isRemoving ? "Remove" : "Update"
        let secondaryAction = isRemoving ? "disable" : "modify"
        return Group {
            Button("\(primaryAction) weight and \(secondaryAction) goals") {
                save()
            }
        }
    }
    
    func save() {
        didSaveWeight(model.sample)
        dismiss()
    }

    func saveConfirmationMessage() -> some View {
        let result = isRemoving
        ? "They will be disabled if you remove this."
        : "They will also be modified if you make this change."
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
    
    @ViewBuilder
    var removeButton: some View {
        if !(model.isRemoved && !model.isUsingMovingAverage) {
            Section {
                Button("Remove") {
                    withAnimation {
                        model.sample.value = nil
                        model.isRemoved = true
                    }
                    focusedType = nil
                }
            }
        }
    }
    
    var valueSection: some View {
        
        var textField: some View {
            let valueBinding = Binding<Double?>(
                get: { model.displayedValue },
                set: { newValue in
                    model.displayedValue = newValue
                    guard let newValue else {
                        model.sample.value = nil
                        return
                    }
                    model.sample.value = settingsStore.bodyMassUnit.convert(newValue, to: .kg)
                }
            )
            
            return BodyMassField(
                unit: $settingsStore.bodyMassUnit,
                valueInKg: valueBinding,
                focusedType: $focusedType,
                healthType: .weight
            )
        }
        
        return Section {
            HStack {
                Text(model.date.adaptiveMaintenanceDateString)
//                    .foregroundStyle(.secondary)
                Spacer()
                if model.isUsingMovingAverage {
                    if let value = model.sample.value {
                        CalculatedBodyMassView(
                            unit: $settingsStore.bodyMassUnit,
                            quantityInKg: .constant(Quantity(value: value)),
                            source: HealthSource.userEntered
                        )
                        .layoutPriority(1)
                    } else {
                        Text("Not enough values")
                            .foregroundStyle(.tertiary)
                    }
                } else if !model.isRemoved {
                    textField
                } else {
                    Button("Set weight") {
                        withAnimation {
                            model.displayedValue = nil
                            model.sample.value = nil
                            model.isRemoved = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            focusedType = .weight
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
        
        let isUsingMovingAverage = Binding<Bool>(
            get: { model.isUsingMovingAverageBinding.wrappedValue },
            set: {
                model.isUsingMovingAverageBinding.wrappedValue = $0
                if $0 == true {
                    focusedType = nil
                } else {
                    focusedType = .weight
                }
            }
        )
        
        var section: some View {
            Section(footer: footer) {
                HStack {
                    Toggle("Use Moving Average", isOn: isUsingMovingAverage)
                }
                if model.isUsingMovingAverage {
                    HStack {
                        Spacer()
                        Text("of the past")
                        Stepper(
                            "",
                            value: model.intervalValueBinding,
                            in: model.movingAverageIntervalPeriod.range
                        )
                        .fixedSize()
                        Text("\(model.movingAverageIntervalValue)")
                            .font(NumberFont)
                            .contentTransition(.numericText(value: Double(model.movingAverageIntervalValue)))
                            .foregroundStyle(.secondary)
                        MenuPicker<HealthPeriod>([.day, .week], model.movingAverageIntervalPeriodBinding)
                    }
                }
            }
        }
        
        return Group {
            if !(model.isRemoved && !model.isUsingMovingAverage) {
                section
            }
        }
    }

    func movingAverageValue(at index: Int) -> Double? {
        guard let value = model.sample.movingAverageValues?[index] else { return nil }
        return BodyMassUnit.kg.convert(value, to: settingsStore.bodyMassUnit)
    }

    @ViewBuilder
    var movingAverageValuesSection: some View {
        if model.isUsingMovingAverage {
            Section("Averaged values") {
                ForEach(0...model.movingAverageNumberOfDays-1, id: \.self) {
                    cell(weight: DatedWeight(
                        value: movingAverageValue(at: $0),
                        date: model.date.moveDayBy(-$0)
                    ))
                }
            }
        }
    }
    
    
    
     func cell(weight: DatedWeight) -> some View {
        NavigationLink(value: weight) {
            WeightCell(weight: weight)
                .environment(settingsStore)
        }
        .navigationDestination(for: DatedWeight.self) { weight in
            averagedWeightForm(weight: weight)
        }
    }
    
    func averagedWeightForm(weight: DatedWeight) -> some View {
        WeightAveragedSampleForm(
            value: weight.value,
            date: weight.date,
            healthModel: healthModel,
            settingsStore: settingsStore,
            didSaveWeight: { didSaveAveragedWeight($0, for: weight.date)}
        )
        .environment(healthModel)
    }
    
    func didSaveAveragedWeight(_ value: Double?, for date: Date) {
        model.saveWeight(value, for: date)
        Task {
            try await healthModel.delegate.updateBackendWeight(
                for: date,
                with: .init(value: value),
                source: .userEntered
            )
        }
    }
    
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Update") {
                if !model.isUsingMovingAverage, requiresSaveConfirmation {
                    showingSaveConfirmation = true
                } else {
                    save()
                }
            }
            .disabled(model.isSaveDisabled)
        }
    }
}

#Preview {
    Text("")
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
                WeightSampleForm(
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
                    settingsStore: SettingsStore.shared,
                    didSave: { value in
                        
                    }
                )
            }
        }
        .onAppear {
            SettingsStore.configureAsMock()
//            resetMockMaintenanceValues()
        }
}
