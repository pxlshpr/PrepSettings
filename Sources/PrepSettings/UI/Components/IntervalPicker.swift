import SwiftUI
import PrepShared

struct IntervalPicker: View {
    
    @Binding var interval: HealthInterval
    
    var value: some View {
        Text("\(interval.value)")
            .font(NumberFont)
            .contentTransition(.numericText(value: Double(interval.value)))
    }
    
    var stepper: some View {
        Stepper(
            "",
            value: $interval.value,
            in: interval.period.range
        )
        .fixedSize()
    }
    
    var periodPicker: some View {
        MenuPicker($interval.period, isPlural: interval.value != 1)
    }
    
    var body: some View {
        Section("Calculated over") {
            HStack {
                value
                stepper
                Spacer()
                periodPicker
            }
        }
    }
}

#Preview {
    @State var interval: HealthInterval = .init(1, .week)
    return NavigationStack {
        Form {
            IntervalPicker(interval: $interval)
        }
    }
}
