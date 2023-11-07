import SwiftUI
import PrepShared
import PrepSettings

struct CalculatedEnergyView<Unit: BiometricUnit, S: GenericSource>: View {
    
    let valueBinding: Binding<Double?>
    let intervalBinding: Binding<HealthInterval?>
    let date: Date
    let unitBinding: Binding<Unit>
    let source: S

    init(
        valueBinding: Binding<Double?>,
        unitBinding: Binding<Unit>,
        intervalBinding: Binding<HealthInterval?>,
        date: Date,
        source: S
    ) {
        self.valueBinding = valueBinding
        self.unitBinding = unitBinding
        self.intervalBinding = intervalBinding
        self.date = date
        self.source = source
    }
    
    var body: some View {
        HStack(alignment: verticalAlignment) {
            if let interval = intervalBinding.wrappedValue {
                prefixText(interval: interval, date: date)
            }
            HStack {
                HStack(spacing: 2) {
                    HealthKitValue(valueBinding, source, showPrecision: false)
                    if value != nil {
                        MenuPicker<Unit>(unitBinding)
                    }
                }
            }
        }
    }
    
    var value: Double? {
        valueBinding.wrappedValue
    }
    
    var verticalAlignment: VerticalAlignment {
        if intervalBinding.wrappedValue?.intervalType == .average {
            .center
        } else {
            .firstTextBaseline
        }
    }

    func dateView(_ date: Date) -> some View {
        Text(date.biometricEnergyFormat)
            .font(.footnote)
            .foregroundStyle(.secondary)
            .padding(.vertical, 3)
            .padding(.horizontal, 5)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .foregroundStyle(Color(.tertiarySystemFill))
            )
            .animation(.default, value: intervalBinding.wrappedValue)
    }
    
    func prefixText(interval: HealthInterval, date: Date) -> some View {
        Group {
            switch interval.intervalType {
            case .average:
//                VStack(alignment: .trailing) {
//                    Text("daily average")
//                        .foregroundStyle(.tertiary)
//                        .animation(.default, value: intervalBinding.wrappedValue)
                    HStack(alignment: .firstTextBaseline) {
//                        Text("from")
//                            .foregroundStyle(.tertiary)
//                            .animation(.default, value: intervalBinding.wrappedValue)
                        dateView(interval.dateRange(with: date).lowerBound)
                        Text("to")
                            .foregroundStyle(.tertiary)
                            .animation(.default, value: intervalBinding.wrappedValue)
                        dateView(interval.dateRange(with: date).upperBound)
                    }
//                }
//                .padding(.vertical, 2)
            default:
                dateView(interval.startDate(with: date))
            }
        }
        .font(.footnote)
        .multilineTextAlignment(.trailing)
    }
}
