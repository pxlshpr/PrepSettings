import SwiftUI
import PrepShared

/// [ ] Design the Energy Expenditure cell for when we don't have enough weight data
/// [ ] Consider having another tag below the one for Calculated/Estimated and have it say the message, e.g. "Insufficient weight data" or "Insufficient food data"
/// [ ] If user taps this tag, pop up a small message elaborating (e.g. "You need to have at least [2 weight measurements/1 day with food logged] over the [past two weeks/two weeks prior] to calculate your expenditure."

public struct MaintenanceForm: View {
    
    @Environment(SettingsStore.self) var settingsStore: SettingsStore

    @Bindable var model: HealthModel

    public init(_ model: HealthModel) {
        self.model = model
    }

    public var body: some View {
        Form {
            MaintenanceFormSections(model)
                .environment(settingsStore)
        }
        .navigationTitle("Maintenance Energy")
        .scrollDismissesKeyboard(.interactively)
    }
}
