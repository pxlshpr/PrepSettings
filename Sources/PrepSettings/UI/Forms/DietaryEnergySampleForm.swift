import SwiftUI
import PrepShared

/**
 [ ]  “Use HealthKit Value” for first row
 [ ] followed by “Do no include this day”, which would 
 [ ] show the footer explaining that the average (state what it is) is being used instead.
 [ ] error row if there are no days entered, letting the user know that at least one day has to be provided (maybe have a way for them to manually enter a value that will be repeated for all days, that they think was their average—so they can start off with this)
 */

typealias DidSaveDietaryEnergySampleHandler = (DietaryEnergySample) -> ()

struct DietaryEnergySampleForm: View {
    
    @Environment(\.dismiss) var dismiss

    @State var model: Model
    @Bindable var healthModel: HealthModel
    @Bindable var settingsStore: SettingsStore

    /// Value that is fetched and stored in the unit that the user has set in `SettingsStore`
    @State var showingSaveConfirmation = false

    let didSave: DidSaveDietaryEnergySampleHandler

    init(
        sample: DietaryEnergySample,
        date: Date,
        healthModel: HealthModel,
        settingsStore: SettingsStore,
        didSave: @escaping DidSaveDietaryEnergySampleHandler
    ) {
        _model = State(initialValue: Model(
            sample: sample,
            date: date,
            healthModel: healthModel
        ))
        self.didSave = didSave
        self.healthModel = healthModel
        self.settingsStore = settingsStore
    }

    var body: some View {
        Form {
            valueSection
            chooseSection
            removeSection
        }
        .navigationTitle("Dietary Energy")
        .navigationBarTitleDisplayMode(.inline)
        .task(model.loadValues)
        .toolbar { toolbarContent }
    }
    
    var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button("Update") {
                didSave(model.sample)
                dismiss()
            }
            .fontWeight(.semibold)
            .disabled(model.saveIsDisabled)
        }
    }
    
    @ViewBuilder
    var removeSection: some View {
        if model.hasValue {
            Section {
                Button("Remove") {
                    withAnimation {
                        model.removeValue()
                    }
                }
            }
        }
    }
    
    var valueSection: some View {
        
        let unitBinding = Binding<EnergyUnit>(
            get: { settingsStore.energyUnit },
            set: { newValue in
                withAnimation {
                    settingsStore.energyUnit = newValue
                }
            }
        )
        
        var footer: some View {
            var string: String {
                switch model.type {
                case .logged:
                    "You are using the logged dietary energy."
                case .healthKit:
                    "You are using the dietary energy data from Apple Health."
//                case .average:
//                    "You are using the average dietary energy consumed for the other days."
                case .userEntered:
                    "You are using a custom entered value."
                default:
                    ""
//                case .notConsumed:
//                    "You have marked this day as having consumed no dietary energy."
                }
            }
         
            return Group {
                if model.hasValue {
                    Text(string)
                } else {
                    EmptyView()
                }
            }
        }
        
        var textField: some View {
            let binding = Binding<Double>(
                get: { model.displayedValue },
                set: { newValue in
                    model.displayedValue = newValue
                    model.sample.value = settingsStore.energyUnit.convert(newValue, to: .kcal)
                }
            )
            return ManualHealthField(
                unitBinding: unitBinding,
                valueBinding: binding,
                firstComponentBinding: .constant(0),
                secondComponentBinding: .constant(0)
            )
        }
        
        @ViewBuilder
        var detail: some View {
            switch model.type {
            case .userEntered:
                textField
            default:
                if let value = model.sample.value(in: settingsStore.energyUnit) {
                    HStack(spacing: UnitSpacing) {
                        Text("\(value.formattedEnergy)")
                            .contentTransition(.numericText(value: value))
//                        MenuPicker(unitBinding)
                        Text(unitBinding.wrappedValue.abbreviation)
                    }
                    .foregroundStyle(.secondary)
                }
            }
        }
        return Section(footer: footer) {
            HStack {
                Text(model.date.adaptiveMaintenanceDateString)
                Spacer()
                if model.sample.value == nil {
                    Button("Set") {
                        withAnimation {
                            model.setValue(energyUnit: settingsStore.energyUnit)
                        }
                    }
                } else {
                    detail
                }
            }
        }
    }
    
    var footer: some View {
        Text("Choose a value you would like to use for this day.\n\nIf the logged value is inaccurate or incomplete, you can choose to use the average of the days in the period you are calculating your maintenance energy for.")
    }
    
//    var chooseSection_: some View {
//        
//        let selection = Binding<DietaryEnergySampleType>(
//            get: { model.type },
//            set: { newValue in
//                withAnimation {
//                    model.type = newValue
//                    model.sample.value = model.value(
//                        for: newValue,
//                        in: settingsStore.energyUnit
//                    )
//                    model.sample.type = newValue
//                }
//            }
//        )
//        
//        var picker: some View {
//            Picker("", selection: selection) {
//                ForEach(DietaryEnergySampleType.userCases, id: \.self) {
//                    cell(type: $0)
//                }
//            }
//            .pickerStyle(.inline)
//        }
//        
//        return Group {
//            if model.sample.value != nil {
//                picker
//            }
//        }
//    }
    
    var chooseSection: some View {
        var section: some View {
            Section {
                ForEach(DietaryEnergySampleType.userCases, id: \.self) {
                    cell(type: $0)
                }
//                Text("Hello")
            }
        }
        
        return Group {
            if model.sample.value != nil {
                section
            }
        }
    }
    func cell(type: DietaryEnergySampleType) -> some View {
        
        var value: Double? {
            model.value(for: type, in: settingsStore.energyUnit)
        }
        
        @ViewBuilder
        var detail: some View {
            if let value {
                HStack(spacing: UnitSpacing) {
                    Text(value.formattedEnergy)
                        .contentTransition(.numericText(value: value))
                    Text(settingsStore.energyUnit.abbreviation)
                }
                .foregroundStyle(Color(.secondaryLabel))
            } else {
                Text("No data")
                    .foregroundStyle(Color(.tertiaryLabel))
            }
        }
        
        var isDisabled: Bool {
            type != .userEntered && value == nil
        }
        
        var labelColor: Color {
            isDisabled ? Color(.tertiaryLabel) : Color(.label)
        }
        
        var checkmark: some View {
            Image(systemName: "checkmark")
                .opacity(model.type == type ? 1 : 0)
        }
        
        var label: some View {
            HStack {
                checkmark
                Text(type.name)
                    .foregroundStyle(labelColor)
                Spacer()
                if type != .userEntered {
                    detail
                }
            }
        }
        
        var button: some View {
            Button {
                withAnimation {
                    model.selected(type)
                }
            } label: {
                label
            }
        }
        
        return button
            .disabled(isDisabled)
    }
}

#Preview {
    Text("")
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
                DietaryEnergySampleForm(
                    sample: .init(type: .logged),
                    date: Date.now,
                    healthModel: MockHealthModel,
                    settingsStore: SettingsStore.shared,
                    didSave: { value in
                        
                    }
                )
                .onAppear { SettingsStore.configureAsMock() }
            }
        }

}
