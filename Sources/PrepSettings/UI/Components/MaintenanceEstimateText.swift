import SwiftUI
import PrepShared

struct MaintenanceEstimateText: View {

    @Bindable var model: HealthModel
    @Bindable var settingsStore: SettingsStore

    init(_ model: HealthModel, _ settingsStore: SettingsStore) {
        self.model = model
        self.settingsStore = settingsStore
    }
    
    var value: Double? {
        model.health.estimatedMaintenance(in: settingsStore.energyUnit)
    }

    @ViewBuilder
    var body: some View {
        if let requiredString = model.health.tdeeRequiredString {
            Text(requiredString)
                .foregroundStyle(Color(.tertiaryLabel))
        } else if let value {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value.formattedEnergy)
                    .animation(.default, value: value)
                    .contentTransition(.numericText(value: value))
                    .font(.system(.body, design: .monospaced, weight: .bold))
                    .foregroundStyle(.secondary)
                Text(settingsStore.energyUnit.abbreviation)
                    .foregroundStyle(.secondary)
                    .font(.system(.body, design: .default, weight: .semibold))
            }
        } else {
            EmptyView()
        }
    }
}
