import SwiftUI
import PrepShared

extension Health.MaintenanceEnergy {
    func weightChangeRow(bodyMassUnit: BodyMassUnit) -> some View {
        HStack {
            Text("Weight Change")
            Spacer()
            if let delta = weightChange.delta(in: bodyMassUnit) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(delta.cleanAmount)")
                        .font(NumberFont)
                        .contentTransition(.numericText(value: Double(delta)))
                    Text(bodyMassUnit.abbreviation)
                }
                .foregroundStyle(.secondary)
            } else {
                Text("Not set")
                    .foregroundStyle(.tertiary)
            }
        }
    }
    
    func equivalentEnergyRow(energyUnit: EnergyUnit) -> some View {
        HStack {
            Text("Equivalent Energy")
            Spacer()
            if let kcal = weightChange.deltaEnergyEquivalent(in: energyUnit) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
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
