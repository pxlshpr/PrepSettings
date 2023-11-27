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

    @State var hasHealthKitValue = false
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
            useHealthKitSection
            doNotIncludeSection
        }
        .navigationTitle("Dietary Energy")
        .navigationBarTitleDisplayMode(.inline)
        .task(loadHasHealthKitValue)
    }
    
    @ViewBuilder
    var useHealthKitSection: some View {
        if hasHealthKitValue {
            Section {
                Toggle("Use HealthKit", isOn: .constant(true))
            }
        }
    }
    
    var doNotIncludeSection: some View {
        Section {
            Toggle("Do not use this day", isOn: .constant(true))
        }
    }
    
    @Sendable
    func loadHasHealthKitValue() async {
        let hasHealthKitValue = false
        await MainActor.run {
            self.hasHealthKitValue = hasHealthKitValue
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
                    sample: .init(type: .backend),
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
