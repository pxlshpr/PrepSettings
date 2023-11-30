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
        .navigationTitle(title)
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
        model.sample.value == nil
    }
    
    func save() {
        didSaveWeight(model.sample)
        dismiss()
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
    
    var title: String {
        "Weight"
    }
    
    @ViewBuilder
    var removeButton: some View {
        if !(model.sample.value == nil && !model.isUsingMovingAverage) {
            Section {
                Button("Remove") {
                    withAnimation {
//                        model.value = nil
                        model.sample.value = nil
                    }
                }
            }
        }
    }
    
    var valueSection: some View {
        
        var textField: some View {
            let valueBinding = Binding<Double>(
                get: { model.displayedValue },
                set: { newValue in
                    model.displayedValue = newValue
                    model.sample.value = settingsStore.bodyMassUnit.convert(newValue, to: .kg)
                }
            )
            
            return ManualHealthField(
                unitBinding: $settingsStore.bodyMassUnit,
                valueBinding: valueBinding,
                firstComponentBinding: $model.weightStonesComponent,
                secondComponentBinding: $model.weightPoundsComponent
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
                } else if model.sample.value != nil {
                    textField
                } else {
                    Button("Set weight") {
                        withAnimation {
//                            model.value = 0
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
                    Toggle("Use Moving Average", isOn: model.isUsingMovingAverageBinding)
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
            if !(model.sample.value == nil && !model.isUsingMovingAverage) {
                section
            }
        }
    }

    func movingAverageValue(at index: Int) -> Double? {
        guard let value = model.sample.movingAverageValues?[index] else { return nil }
        return BodyMassUnit.kg.convert(value, to: settingsStore.bodyMassUnit)
    }

    var movingAverageValuesSection: some View {
        
        var footer: some View {
//            Text("The average of these values is being used.")
            EmptyView()
        }
        
        func cell(_ index: Int) -> some View {
            
            @ViewBuilder
            var valueText: some View {
                if let value = movingAverageValue(at: index) {
                    HStack(alignment: .firstTextBaseline, spacing: UnitSpacing) {
                        Text(value.healthString)
                            .font(NumberFont)
                            .animation(.default, value: value)
                            .contentTransition(.numericText(value: value))
                            .foregroundStyle(Color(.secondaryLabel))
                        Text(settingsStore.bodyMassUnit.abbreviation)
                            .foregroundStyle(.secondary)
                    }
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
            
            func didSaveWeight(_ value: Double?) {
                model.saveWeight(value, at: index)
                Task {
                    try await healthModel.delegate.updateBackendWeight(
                        for: date,
                        with: .init(value: value),
                        source: .userEntered
                    )
                }
            }
            
            return NavigationLink {
                WeightMovingAverageComponentForm(
                    value: movingAverageValue(at: index),
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
