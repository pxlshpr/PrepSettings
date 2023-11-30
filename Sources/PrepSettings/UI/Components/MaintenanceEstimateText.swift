import SwiftUI
import PrepShared

public let UnitSpacing: CGFloat? = nil
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
            HStack(alignment: .firstTextBaseline, spacing: UnitSpacing) {
                Text(value.formattedEnergy)
                    .animation(.default, value: value)
                    .contentTransition(.numericText(value: value))
                    .font(NumberFont)
                    .foregroundStyle(.secondary)
                Text(settingsStore.energyUnit.abbreviation)
                    .foregroundStyle(.secondary)
//                    .font(.system(.body, design: .default, weight: .semibold))
            }
        } else {
            EmptyView()
        }
    }
}
