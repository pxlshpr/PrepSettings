import SwiftUI
import PrepShared

struct DietaryEnergySampleCell: View {

    @Environment(SettingsStore.self) var settingsStore: SettingsStore

    let sample: MaintenanceDietaryEnergySample
    let date: Date
    
    init(sample: MaintenanceDietaryEnergySample, date: Date) {
        self.sample = sample
        self.date = date
    }
    
    var body: some View {
        HStack {
            Text(date.adaptiveMaintenanceDateString)
            Spacer()
            healthKitIcon
            value
        }
    }
    
    @ViewBuilder
    var value: some View {
        if sample.type != .averaged, let value = sample.value(in: settingsStore.energyUnit) {
            HStack(spacing: 4) {
                Text(value.formattedEnergy)
                    .font(NumberFont)
                    .contentTransition(.numericText(value: Double(value)))
                Text(settingsStore.energyUnit.abbreviation)
            }
            .foregroundStyle(.secondary)
        } else {
            Text("Using average")
                .foregroundStyle(.tertiary)
        }
    }
    
    @ViewBuilder
    var healthKitIcon: some View {
        if sample.type == .healthKit {
            Image(packageResource: "AppleHealthIcon", ofType: "png")
                .resizable()
                .frame(width: 25, height: 25)
        }
    }
}
