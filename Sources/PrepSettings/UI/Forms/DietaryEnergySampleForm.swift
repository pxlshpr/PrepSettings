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
        _model = State(initialValue: Model(sample: sample, date: date))
        self.didSave = didSave
        self.healthModel = healthModel
        self.settingsStore = settingsStore
    }

    var body: some View {
        Form {
            valueSection
            chooseSection
        }
        .navigationTitle("Dietary Energy")
        .navigationBarTitleDisplayMode(.inline)
        .task(model.loadValues)
    }
    
    func value(for type: DietaryEnergySampleType) -> Double? {
        guard let valueInKcal = model.valueInKcal(for: type) else { return nil }
        return EnergyUnit.kcal.convert(valueInKcal, to: settingsStore.energyUnit)
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
                case .average:
                    "You are using the average dietary energy consumed for the other days."
                case .userEntered:
                    "You are using a custom entered value."
                case .notConsumed:
                    "You have marked this day as having consumed no dietary energy."
                }
            }
            
            return Text(string)
        }
        
        @ViewBuilder
        var detail: some View {
            switch model.type {
            case .userEntered:
                ManualHealthField(
                    unitBinding: unitBinding,
                    valueBinding: .constant(0),
                    firstComponentBinding: .constant(0),
                    secondComponentBinding: .constant(0)
                )
            default:
                if let value = value(for: model.type) {
                    HStack(spacing: 2) {
                        Text("\(value.formattedEnergy)")
                            .foregroundStyle(.secondary)
                            .contentTransition(.numericText(value: value))
                        MenuPicker(unitBinding)
                    }
                }
            }
        }
        return Section(footer: footer) {
            HStack {
                Text(model.date.adaptiveMaintenanceDateString)
                Spacer()
                detail
            }
        }
    }
    
    var footer: some View {
        Text("Choose a value you would like to use for this day.\n\nIf the logged value is inaccurate or incomplete, you can choose to use the average of the days in the period you are calculating your maintenance energy for.")
    }
    
    var chooseSection: some View {
        
        let selection = Binding<DietaryEnergySampleType>(
            get: { model.type },
            set: { newValue in
                withAnimation {
                    model.type = newValue
                }
            }
        )
        
        return Picker("Source", selection: selection) {
            ForEach(DietaryEnergySampleType.allCases, id: \.self) {
                cell(type: $0)
            }
        }
        .pickerStyle(.inline)
    }
    
    func haveValue(for type: DietaryEnergySampleType) -> Bool {
        value(for: type) != nil
    }
    
    @ViewBuilder
    func cell(type: DietaryEnergySampleType) -> some View {
        if type == .userEntered || haveValue(for: type) {
            HStack {
                Text(type.name)
                    .foregroundStyle(Color(.label))
                Spacer()
                if type != .userEntered, let value = value(for: type) {
                    HStack(spacing: 2) {
                        Text(value.formattedEnergy)
                            .contentTransition(.numericText(value: value))
                        Text(settingsStore.energyUnit.abbreviation)
                    }
                    .foregroundStyle(Color(.secondaryLabel))
                }
            }
        }
    }
}

extension DietaryEnergySampleForm {
    @Observable class Model {
        let initialSample: DietaryEnergySample
        var sample: DietaryEnergySample
        
        let date: Date
        var value: Double?
        var displayedValue: Double {
            didSet {
                value = displayedValue
                sample.value = displayedValue
            }
        }
        
        var fetchedValuesInKcal: [DietaryEnergySampleType: Double] = [:]

        var type: DietaryEnergySampleType

        init(sample: DietaryEnergySample, date: Date) {
            self.initialSample = sample
            self.sample = sample
            self.value = sample.value
            self.displayedValue = sample.value ?? 0
            self.date = date
            self.type = sample.type
        }

    }
}

extension DietaryEnergySampleForm.Model {
    func valueInKcal(for type: DietaryEnergySampleType) -> Double? {
        switch type {
        case .userEntered:  value
        default:            fetchedValuesInKcal[type]
        }
    }
    
    @Sendable
    func loadValues() async {
        await MainActor.run {
            fetchedValuesInKcal = [
                .healthKit: 1024,
                .logged: 1526,
                .average: 1852,
//                .notConsumed: 0
            ]
        }
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
