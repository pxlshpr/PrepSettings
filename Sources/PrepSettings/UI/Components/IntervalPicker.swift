import SwiftUI
import PrepShared

struct IntervalPicker: View {
    
    @Binding var interval: HealthInterval
    let periods: [HealthPeriod]?
    let ranges: [HealthPeriod: ClosedRange<Int>]?
    let title: String?
    
    init(
        interval: Binding<HealthInterval>,
        periods: [HealthPeriod]? = nil,
        ranges: [HealthPeriod: ClosedRange<Int>]? = nil,
        title: String? = nil
    ) {
        _interval = interval
        self.periods = periods
        self.ranges = ranges
        self.title = title
    }
    
    var value: some View {
        Text("\(interval.value)")
            .font(NumberFont)
            .contentTransition(.numericText(value: Double(interval.value)))
    }
    
    func range(for period: HealthPeriod) -> ClosedRange<Int> {
        ranges?[period] ?? 1...period.maxValue
    }
    
    var stepper: some View {
        
        return Stepper(
            "",
            value: $interval.value,
            in: range(for: interval.period)
        )
        .fixedSize()
    }
    
    var periodBinding: Binding<HealthPeriod> {
        Binding<HealthPeriod>(
            get: {
                interval.period
            },
            set: { newValue in
                interval.period = newValue

                /// If  a range for this period was provided
                let range = range(for: newValue)

                /// Ensure the value is within the range
                if interval.value < range.lowerBound {
                    interval.value = range.lowerBound
                }
                if interval.value > range.upperBound {
                    interval.value = range.upperBound
                }
            }
        )
    }
    
    @ViewBuilder
    var periodPicker: some View {
        if let periods {
            MenuPicker(
                periods,
                periodBinding,
                isPlural: interval.value != 1
            )
        } else {
            MenuPicker(
                $interval.period,
                isPlural: interval.value != 1
            )
        }
    }
    
    @ViewBuilder
    var header: some View {
        if let title {
            Text(title)
        }
    }
    
    var body: some View {
        Section(header: header) {
            HStack {
                value
                stepper
                Spacer()
                periodPicker
            }
        }
    }
}

struct HealthIntervalTest: View {
    @State var interval: HealthInterval = .init(2, .week)
    
    var body: some View {
        NavigationStack {
            Form {
                IntervalPicker(
                    interval: $interval,
                    periods: [.day, .week],
                    ranges: [
                        .day: 3...6
                    ]
                )
            }
        }
    }
}

#Preview {
    HealthIntervalTest()
}
