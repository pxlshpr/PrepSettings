import SwiftUI
import PrepShared

struct MaintenanceCalculatedSection: View {
    
    enum Route {
        case calculation
    }
    
    @Environment(SettingsStore.self) var settingsStore: SettingsStore

    @Bindable var model: HealthModel

    init(_ model: HealthModel) {
        self.model = model
    }

    var body: some View {
//        toggleRow
        Section(footer: footer) {
            calculatedRow
        }
    }
    
    var calculatedRow: some View {
        NavigationLink(value: Route.calculation) {
            HStack {
                Text("Adaptive")
                Spacer()
                if let value = model.health.calculatedMaintenanceValue(in: settingsStore.energyUnit) {
                    Text("\(value.formattedEnergy) \(settingsStore.energyUnit.abbreviation)")
                        .foregroundStyle(.secondary)
                } else {
                    Text("Not set")
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .navigationDestination(for: Route.self) { route in
            switch route {
            case .calculation:
                MaintenanceCalculateView(model)
                    .environment(settingsStore)
            }
        }
    }
    
    //MARK: - Legacy

    var body_: some View {
        Section(footer: footer) {
            toggleRow
            showCalculationRow
            errorRow
        }
    }

    var health: Health {
        model.health
    }
    
    var footer: some View {
//                Text("Adaptively calculate your \(HealthType.maintenanceEnergy.abbreviation) based on your weight change and dietary energy over the prior week. [Learn More.](https://example.com)")
//        Text("Compares your weight change to the dietary energy you consumed to determine your adaptive maintenance. [Learn More.](https://example.com)")
        Text("Compares weight change to dietary energy consumed to determine your true maintenance, continuously adapting it to changes.")
    }
    
    var toggleRow: some View {
        HStack {
            Text("Adaptive Maintenance")
//                    Text("Use Adaptive Calculation")
                .layoutPriority(1)
            Spacer()
            Toggle("", isOn: $model.maintenanceEnergyIsAdaptive)
        }
    }

    @ViewBuilder
    var showCalculationRow: some View {
        if model.maintenanceEnergyIsAdaptive {
            NavigationLink(value: Route.calculation) {
                Text("Show Calculation")
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .calculation:
                    MaintenanceCalculateView(model)
                        .environment(settingsStore)
                }
            }
        }
    }
    
    @ViewBuilder
    var errorRow: some View {
        if let error = model.health.maintenanceEnergy?.error {
            MaintenanceCalculationErrorCell(error)
        }
    }
}

#Preview {
    Text("")
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
//                HealthSummary(model: MockHealthModel)
//                    .environment(SettingsStore.shared)
                HealthForm(MockHealthModel, [.maintenanceEnergy])
                    .environment(SettingsStore.shared)
            }
        }
}
