import SwiftUI
import PrepShared

struct DatedWeight: Hashable {
    let value: Double?
    let date: Date
}

struct WeightCell: View {
    
    @Environment(SettingsStore.self) var settingsStore: SettingsStore
    
    let weight: DatedWeight
    
    var body: some View {
        HStack {
            dateText
            Spacer()
            valueText
        }
    }
    
    @ViewBuilder
    var valueText: some View {
        if let value = weight.value {
            HStack(alignment: .firstTextBaseline, spacing: UnitSpacing) {
                Text(value.healthString)
                    .font(NumberFont)
                    .animation(.default, value: value)
                    .contentTransition(.numericText(value: value))
                    .foregroundStyle(Color(.secondaryLabel))
                Text(settingsStore.bodyMassUnit.abbreviation)
                    .foregroundStyle(.secondary)
            }
        } else {
            Text("Not set")
                .foregroundStyle(.tertiary)
        }
    }
    
    var dateText: some View {
        Text(weight.date.adaptiveMaintenanceDateString)
    }
}
