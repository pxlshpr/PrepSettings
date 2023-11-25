import SwiftUI
import PrepShared

extension Health.MaintenanceEnergy {
    var weightChangeRow: some View {
        HStack {
            Text("Weight Change")
            Spacer()
            if let delta = weightChange.delta {
                Text("\(delta.cleanAmount) kg")
                    .foregroundStyle(.secondary)
            } else {
                Text("Not set")
                    .foregroundStyle(.tertiary)
            }
        }
    }
    
    var equivalentEnergyRow: some View {
        HStack {
            Text("Equivalent Energy")
            Spacer()
            if let kcal = weightChange.deltaEquivalentEnergyInKcal {
                Text("\(kcal.formattedEnergy) kcal")
                    .foregroundStyle(.secondary)
            } else {
                Text("Not set")
                    .foregroundStyle(.tertiary)
            }
        }
    }
}
