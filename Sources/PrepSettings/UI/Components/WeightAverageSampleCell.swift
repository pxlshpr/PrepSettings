import SwiftUI
import PrepShared

struct DatedWeight: Hashable {
    let date: Date
    let value: Double?
    let source: HealthSource?
    let isDailyAverage: Bool?
    
    init(
        date: Date,
        value: Double? = nil,
        source: HealthSource? = nil,
        isDailyAverage: Bool? = nil
    ) {
        self.date = date
        self.value = value
        self.source = source
        self.isDailyAverage = isDailyAverage
    }
    
    init(date: Date, healthQuantity: HealthQuantity) {
        self.date = date
        self.value = healthQuantity.quantity?.value
        self.source = healthQuantity.source
        self.isDailyAverage = healthQuantity.isDailyAverage
    }
}

struct WeightCell: View {
    
    @Environment(SettingsStore.self) var settingsStore: SettingsStore
    
    let date: Date
    let weight: HealthDetails.Weight
    
    var body: some View {
        HStack {
            dateText
            Spacer()
            valueText
        }
    }
    
    @ViewBuilder
    var valueText: some View {
        if let value = weight.valueInKg {
            HStack(alignment: .firstTextBaseline, spacing: UnitSpacing) {
                Text("\(value.clean) \(settingsStore.bodyMassUnit.abbreviation)")
            }
        } else {
            Text("Not Set")
                .foregroundStyle(.secondary)
        }
    }
    
    var dateText: some View {
        Text(date.adaptiveMaintenanceDateString)
    }
}
