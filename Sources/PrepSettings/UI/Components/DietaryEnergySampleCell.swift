import SwiftUI
import PrepShared

struct DietaryEnergySampleCell: View {

    @Environment(SettingsStore.self) var settingsStore: SettingsStore

    let sample: DietaryEnergySample
    let date: Date
    
    init(sample: DietaryEnergySample, date: Date) {
        self.sample = sample
        self.date = date
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(date.adaptiveMaintenanceDateString)
                Spacer()
                value
            }
        }
    }
    
    var typeView: some View {
        TagView(string: sample.type.name)
    }
    
    @ViewBuilder
    var value: some View {
        if let value = sample.value(in: settingsStore.energyUnit), sample.type != .average {
            HStack(spacing: UnitSpacing) {
                Text(value.formattedEnergy)
                    .font(NumberFont)
                    .contentTransition(.numericText(value: Double(value)))
                Text(settingsStore.energyUnit.abbreviation)
            }
            .foregroundStyle(.secondary)
        } else {
            Text("Not set")
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

#Preview {
    let samples: [DietaryEnergySample] = [
        .init(type: .logged, value: 1500),
//        .init(type: .average, value: 1500),
        .init(type: .healthKit, value: 1500),
//        .init(type: .notConsumed, value: 1500),
        .init(type: .userEntered, value: 1500),
        .init(type: .userEntered, value: 0),
        .init(type: .userEntered, value: nil),
    ]
    return NavigationStack {
        List {
            ForEach(samples, id: \.self) { sample in
                NavigationLink {
                    
                } label: {
                    DietaryEnergySampleCell(sample: sample, date: Date.now)
                        .environment(SettingsStore.shared)
                }
            }
        }
    }
}
