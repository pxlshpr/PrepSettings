import SwiftUI
import PrepShared

extension Health.Maintenance.Adaptive {
    
    @ViewBuilder
    func weightChangeValueText(bodyMassUnit: BodyMassUnit) -> some View {
        if let delta = weightChange.delta(in: bodyMassUnit) {
            HStack(alignment: .firstTextBaseline, spacing: UnitSpacing) {
                Text("\(delta.cleanAmount)")
                    .font(NumberFont)
                    .contentTransition(.numericText(value: Double(delta)))
                Text(bodyMassUnit.abbreviation)
            }
            .foregroundStyle(.secondary)
        } else {
            Text("Not set")
//            Text("Set weights")
//            switch (weightChange.previous.value == nil, weightChange.current.value == nil) {
//            case (true, true):
//                Text("Set weights")
                    .foregroundStyle(.tertiary)
//            case (false, true):
//                Text("Set current weight")
//                    .foregroundStyle(.tertiary)
//            case (true, false):
//                Text("Set previous weight")
//                    .foregroundStyle(.tertiary)
//            case (false, false):
//                Text("Not set")
//                    .foregroundStyle(.tertiary)
//            }
        }
    }
    
    func weightChangeRow(bodyMassUnit: BodyMassUnit) -> some View {
        HStack {
            Text("Change")
            Spacer()
            weightChangeValueText(bodyMassUnit: bodyMassUnit)
        }
    }
    
    func equivalentEnergyRow(energyUnit: EnergyUnit) -> some View {
        HStack {
            Text("Equivalent Energy")
            Spacer()
            if let kcal = weightChange.deltaEnergyEquivalent(in: energyUnit) {
                HStack(alignment: .firstTextBaseline, spacing: UnitSpacing) {
                    Text("\(kcal.formattedEnergy)")
                        .font(NumberFont)
                        .contentTransition(.numericText(value: Double(kcal)))
                    Text(energyUnit.abbreviation)
                }
                .foregroundStyle(.secondary)
            } else {
                Text("Not set")
                    .foregroundStyle(.tertiary)
            }
        }
    }
}
