import SwiftUI
import PrepShared

public struct EstimatedMaintenanceForm: View {
    
    @Environment(SettingsStore.self) var settingsStore: SettingsStore
    @Bindable var model: HealthModel
    @State var hasAppeared = false
    
    public init(_ model: HealthModel) {
        self.model = model
    }
    
    public var body: some View {
        Group {
            if hasAppeared {
                form
            } else {
                Color.clear
            }
        }
        .onAppear(perform: appeared)
        .navigationTitle("Estimated Maintenance")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var form: some View {
        Form {
            restingEnergySection
            activeEnergySection
            estimateSection
        }
    }
    var restingEnergySection: some View {
        var footer: some View {
            Text(HealthType.restingEnergy.reason!)
        }
        return Section(footer: footer) {
            HealthLink(type: .restingEnergy)
                .environment(settingsStore)
                .environment(model)
        }
    }
    
    var activeEnergySection: some View {
        var footer: some View {
            Text(HealthType.activeEnergy.reason!)
        }
        
        return Section(footer: footer) {
            HealthLink(type: .activeEnergy)
                .environment(settingsStore)
                .environment(model)
        }
    }
    
    func appeared() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            hasAppeared = true
        }
    }

    var estimateSection: some View {
        var content: some View {
            
            func content(_ value: Double) -> some View {
                LargeHealthValue(
                    value: value,
                    valueString: value.formattedEnergy,
                    unitString: "\(settingsStore.energyUnit.abbreviation) / day"
                )
            }
            
            var value: Double? {
                model.health.estimatedMaintenance(in: settingsStore.energyUnit)
            }
            
            return Group {
                if let value {
                    content(value)
                } else {
                    Text("Not Set")
                        .foregroundStyle(.tertiary)
                }
            }
        }
        
        var footer: some View {
            Text("Your estimated resting and active energies are added to get an estimate of your maintenance.")
        }
        
        return Section(footer: footer) {
            HStack {
                Spacer()
                content
            }
        }
    }
}

struct HealthLink: View {
    
    @Environment(SettingsStore.self) var settingsStore: SettingsStore
    @Environment(HealthModel.self) var model: HealthModel
    let type: HealthType
    
    var body: some View {
        NavigationLink(value: type) {
            label
        }
        .navigationDestination(for: HealthType.self) { type in
            HealthForm(model, [type])
                .environment(settingsStore)
        }
    }
    
    var label: some View {
        HStack {
            Text(type.name)
            Spacer()
            if let string = model.health.summaryDetail(for: type) {
                Text(string)
            } else {
                Text("Not Set")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    Text("")
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
                EstimatedMaintenanceForm(MockCurrentHealthModel)
                    .environment(SettingsStore.shared)
            }
        }
}
