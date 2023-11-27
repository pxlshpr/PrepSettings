import SwiftUI
import PrepShared

/**
 [ ]  “Use HealthKit Value” for first row
 [ ] followed by “Do no include this day”, which would 
 [ ] show the footer explaining that the average (state what it is) is being used instead.
 [ ] error row if there are no days entered, letting the user know that at least one day has to be provided (maybe have a way for them to manually enter a value that will be repeated for all days, that they think was their average—so they can start off with this)
 */

typealias DidSaveDietaryEnergySampleHandler = (MaintenanceDietaryEnergySample) -> ()

struct DietaryEnergySampleForm: View {
    
    @Environment(\.dismiss) var dismiss

    @State var model: Model
    @Bindable var healthModel: HealthModel
    @Bindable var settingsStore: SettingsStore

    /// Value that is fetched and stored in the unit that the user has set in `SettingsStore`
    @State var values: [MaintenanceDietaryEnergySampleType: Double] = [:]
    @State var showingSaveConfirmation = false

    let didSave: DidSaveDietaryEnergySampleHandler

    init(
        sample: MaintenanceDietaryEnergySample,
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
            chooseSection
//            useHealthKitSection
//            doNotIncludeSection
        }
        .navigationTitle("Dietary Energy")
//        .navigationTitle(model.date.adaptiveMaintenanceDateString)
        .navigationBarTitleDisplayMode(.inline)
        .task(loadValues)
    }
    
    var footer: some View {
        Text("Choose a value you would like to use for this day.\n\nIf the logged value is inaccurate or incomplete, you can choose to use the average of the days in the period you are calculating your maintenance energy for.")
    }
    
    @State var type: MaintenanceDietaryEnergySampleType = .average
    
    var chooseSection: some View {
//        Section(footer: footer) {
            Picker(model.date.adaptiveMaintenanceDateString, selection: $model.type) {
                ForEach(MaintenanceDietaryEnergySampleType.allCases, id: \.self) {
//                    Text($0.name)
                    cell(for: $0)
                }
            }
            .pickerStyle(.inline)
//            .pickerStyle(.menu)

//            cell("Logged", value: 1526, isSelected: true)
//            if let healthKitValue {
//                cell("Apple Health", value: 1025, isSelected: false)
//            }
//            cell("Average", value: 1852, isSelected: false)
//            cell("Not consumed", value: 0, isSelected: false)
//        }
    }
    
    @ViewBuilder
    func cell(for type: MaintenanceDietaryEnergySampleType) -> some View {
        if let value = values[type] {
//            Text(type.name)
            cell(type.name, value: value, isSelected: typeIsSelected(type))
        }
    }
    
    func typeIsSelected(_ type: MaintenanceDietaryEnergySampleType) -> Bool {
        false
    }
    
    func cell(_ label: String, value: Double, isSelected: Bool) -> some View {
//        Button {
            
//        } label: {
            HStack {
                Text(label)
                    .foregroundStyle(Color(.label))
                Spacer()
                Text("\(value.formattedEnergy) kcal")
                    .foregroundStyle(Color(.secondaryLabel))
//                Image(systemName: "checkmark")
//                    .opacity(isSelected ? 1 : 0)
            }
//        }
    }
    
    @Sendable
    func loadValues() async {
        await MainActor.run {
            self.values = [
                .healthKit: 1024,
                .logged: 1526,
                .average: 1852,
//                .notConsumed: 0
            ]
        }
    }
    
}

extension DietaryEnergySampleForm {
    @Observable class Model {
        let initialSample: MaintenanceDietaryEnergySample
        var sample: MaintenanceDietaryEnergySample
        
        let date: Date
        var value: Double?
        var displayedValue: Double {
            didSet {
                value = displayedValue
                sample.value = displayedValue
            }
        }
        
        var type: MaintenanceDietaryEnergySampleType

        init(sample: MaintenanceDietaryEnergySample, date: Date) {
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
