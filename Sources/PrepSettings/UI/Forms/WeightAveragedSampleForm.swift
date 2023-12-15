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
    
    @FocusState var focusedType: HealthType?

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

    func saveConfirmationActions() -> some View {
        let primaryAction = isRemoving ? "Remove" : "Update"
        let secondaryAction = isRemoving ? "disable" : "modify"
        return Group {
            Button("\(primaryAction) weight and \(secondaryAction) goals") {
                save()
            }
        }
    }
    
    var isRemoving: Bool {
        model.isRemoved || model.valueInKg == nil
    }
    
    func saveConfirmationMessage() -> some View {
        let result = isRemoving
        ? "They will be disabled if you remove this."
        : "They will also be modified if you update this change."
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
            Button("Update") {
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
            
            let binding = Binding<Double?>(
                get: { model.displayedValue },
                set: { newValue in
                    model.displayedValue = newValue
                    guard let newValue else {
                        model.valueInKg = nil
                        return
                    }
                    model.valueInKg = settingsStore.bodyMassUnit.convert(newValue, to: .kg)
                }
            )
            
            return BodyMassField(
                unit: $settingsStore.bodyMassUnit,
                valueInKg: binding,
                focusedType: $focusedType,
                healthType: .weight,
                disabled: .constant(false)
            )
            
//            return HealthNumberField(
//                unitBinding: $settingsStore.bodyMassUnit,
//                valueBinding: binding,
//                firstComponentBinding: $model.weightStonesComponent,
//                secondComponentBinding: $model.weightPoundsComponent
//            )
        }
        
        return Section {
            HStack {
                Text(model.date.adaptiveMaintenanceDateString)
                Spacer()
                if model.isRemoved {
                    Button("Set") {
                        withAnimation {
                            model.valueInKg = 0
                            model.displayedValue = 0
                            model.isRemoved = true
                        }
                        focusedType = .weight
                    }
                } else {
                    textField
                }
            }
        }
    }
    
    @ViewBuilder
    var removeButton: some View {
        if !model.isRemoved {
            Section {
                Button("Remove") {
                    withAnimation {
                        model.valueInKg = nil
                        model.isRemoved = true
                    }
                    focusedType = nil
                }
            }
        }
    }
}
