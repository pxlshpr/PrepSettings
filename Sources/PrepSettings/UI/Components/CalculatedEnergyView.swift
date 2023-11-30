import SwiftUI
import PrepShared

struct CalculatedEnergyView<S: GenericSource>: View {
    
    let valueInKcalBinding: Binding<Double?>
    let unitBinding: Binding<EnergyUnit>
    
    let intervalBinding: Binding<HealthInterval?>
    let date: Date
    let source: S

    init(
        valueBinding: Binding<Double?>,
        unitBinding: Binding<EnergyUnit>,
        intervalBinding: Binding<HealthInterval?>,
        date: Date,
        source: S
    ) {
        self.valueInKcalBinding = valueBinding
        self.unitBinding = unitBinding
        self.intervalBinding = intervalBinding
        self.date = date
        self.source = source
    }
    
    var valueInKcal: Double? {
        valueInKcalBinding.wrappedValue
    }
    
    var unit: EnergyUnit {
        unitBinding.wrappedValue
    }

    var valueBinding: Binding<Double?> {
        Binding<Double?>(
            get: {
                guard let valueInKcal else { return nil }
                return EnergyUnit.kcal.convert(valueInKcal, to: unit)
            },
            set: { newValue in
                guard let newValue else {
                    valueInKcalBinding.wrappedValue = nil
                    return
                }
                let valueInKcal = unit.convert(newValue, to: .kcal)
                valueInKcalBinding.wrappedValue = valueInKcal
            }
        )
    }
    
    var body: some View {
        HStack(alignment: verticalAlignment) {
            if let interval = intervalBinding.wrappedValue {
                prefixText(interval: interval, date: date)
            }
            HStack(spacing: UnitSpacing) {
                HealthKitValueView(valueBinding, source, showPrecision: false)
                if value != nil {
//                    MenuPicker(unitBinding)
                    Text(unitBinding.wrappedValue.abbreviation)
                        .foregroundStyle(.secondary)
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
        Text(date.healthEnergyFormat)
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
