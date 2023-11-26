import SwiftUI
import PrepShared

struct HealthEnergyIntervalField: View {
    
    let type: HealthIntervalType
    @Binding var value: Int
    @Binding var period: HealthPeriod
    
    @ViewBuilder
    var body: some View {
        if type == .average {
            HStack {
                Spacer()
                Text("of the past")
                Stepper("", value: $value, in: period.range)
                    .fixedSize()
                Text("\(value)")
                    .font(NumberFont)
                    .contentTransition(.numericText(value: Double(value)))
                    .foregroundStyle(.secondary)
                MenuPicker<HealthPeriod>($period)
            }
        }
    }
}
