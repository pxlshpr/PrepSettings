import SwiftUI
import PrepShared

struct WeightSampleCell: View {
    
    @Environment(SettingsStore.self) var settingsStore
    
    let sample: WeightSample
    let date: Date
    
    init(sample: WeightSample, date: Date) {
        self.sample = sample
        self.date = date
    }
    
    @ViewBuilder
    var value: some View {
        if let value = sample.value(in: settingsStore.bodyMassUnit) {
            HStack(alignment: .firstTextBaseline, spacing: UnitSpacing) {
                Text("\(value.rounded(toPlaces: 1).cleanAmount)")
                    .font(NumberFont)
                    .contentTransition(.numericText(value: Double(value)))
                Text(settingsStore.bodyMassUnit.abbreviation)
            }
            .foregroundStyle(.secondary)
        } else {
            Text("Not Set")
                .foregroundStyle(.tertiary)
        }
    }
    
    var body: some View {
        HStack {
            Text(date.adaptiveMaintenanceDateString)
//                .foregroundStyle(.secondary)
            Spacer()
            value
//            averageLabel
        }
    }
    
//    @ViewBuilder
//    var averageLabel: some View {
//        if type == .averaged {
//            TagView(string: "Average")
//        }
//    }
}

