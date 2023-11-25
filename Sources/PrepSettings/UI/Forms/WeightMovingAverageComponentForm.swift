import SwiftUI
import PrepShared

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
