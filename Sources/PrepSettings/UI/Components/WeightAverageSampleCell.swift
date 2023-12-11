import SwiftUI
import PrepShared

struct DatedWeight: Hashable {
    let date: Date
    let value: Double?
    let source: HealthSource?
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
                Text("\(value.clean) \(settingsStore.bodyMassUnit.abbreviation)")
            }
        } else {
            Text("Not Set")
                .foregroundStyle(.secondary)
        }
    }
    
    var dateText: some View {
        Text(weight.date.adaptiveMaintenanceDateString)
    }
}
