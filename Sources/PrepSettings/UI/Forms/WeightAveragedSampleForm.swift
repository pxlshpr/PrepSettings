import SwiftUI
import PrepShared

struct WeightAveragedSampleForm: View {

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
        _model = State(initialValue: Model(
            value: value,
            date: date
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
        model.valueInKg == nil
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
        didSaveWeight(model.valueInKg)
        dismiss()
    }

    var valueSection: some View {
        var textField: some View {
            
            let binding = Binding<Double>(
                get: { model.displayedValue },
                set: { newValue in
                    model.displayedValue = newValue
                    model.valueInKg = settingsStore.bodyMassUnit.convert(newValue, to: .kg)
                }
            )
            
            return ManualHealthField(
                unitBinding: $settingsStore.bodyMassUnit,
                valueBinding: binding,
                firstComponentBinding: $model.weightStonesComponent,
                secondComponentBinding: $model.weightPoundsComponent
            )
        }
        
        return Section {
            HStack {
                Text(model.date.adaptiveMaintenanceDateString)
                Spacer()
                if model.valueInKg == nil {
                    Button("Set") {
                        withAnimation {
                            model.valueInKg = 0
                            model.displayedValue = 0
                        }
                    }
                } else {
                    textField
                }
            }
        }
    }
    
    @ViewBuilder
    var removeButton: some View {
        if model.valueInKg != nil {
            Section {
                Button("Remove") {
                    withAnimation {
                        model.valueInKg = nil
                    }
                }
            }
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
                    date: Date.now,
                    healthModel: MockHealthModel,
                    settingsStore: SettingsStore.shared,
                    didSave: { value in
                        
                    }
                )
                
//                WeightMovingAverageComponentForm(
//                    value: 93.5,
//                    date: Date.now,
//                    healthModel: MockHealthModel,
//                    settingsStore: SettingsStore.shared,
//                    didSaveWeight: { weight in
//                    }
//                )
            }
        }
}
