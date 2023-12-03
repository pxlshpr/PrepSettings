import SwiftUI
import PrepShared


public struct MaintenanceCalculationSection: View {
    
    enum Route {
        case calculation
    }
    
    @Environment(SettingsStore.self) var settingsStore: SettingsStore

    @Bindable var model: HealthModel

    public init(_ model: HealthModel) {
        self.model = model
    }

    public var body: some View {
        Group {
            maintenanceSection
            calculateSection
        }
    }

    var health: Health {
        model.health
    }
    
    var calculateSection: some View {
        var footer: some View {
//                Text("Adaptively calculate your \(HealthType.maintenanceEnergy.abbreviation) based on your weight change and dietary energy over the prior week. [Learn More.](https://example.com)")
            Text("Compares your weight change to the dietary energy you consumed to determine your adaptive maintenance. [Learn More.](https://example.com)")
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

        return Section(footer: footer) {
            toggleRow
            showCalculationRow
            errorRow
        }
    }
    
    var maintenanceSection: some View {
        var footer: some View {
//                Text("Your \(HealthType.maintenanceEnergy.abbreviation) is used in energy goals, when targeting a desired weight change.")
            Text(HealthType.maintenanceEnergy.reason!)
        }
        return Section(footer: footer) {
            MaintenanceEnergyRow(model)
                .environment(settingsStore)
        }
    }
}

public struct MaintenanceEstimateSection: View {
    
    enum Route {
        case estimate
    }
    
    @Environment(SettingsStore.self) var settingsStore: SettingsStore

    @Environment(HealthModel.self) var model: HealthModel

    public var body: some View {
        Section(footer: footer) {
            NavigationLink(value: Route.estimate) {
                label
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .estimate:
                    MaintenanceEstimateView(model)
                        .environment(settingsStore)
                }
            }
        }
    }
    @ViewBuilder
    var footer: some View {
        if model.maintenanceEnergyIsAdaptive {
            Text("This estimate is used when there isn't sufficient weight or nutrition data to make a calculation.")
        }
    }
    
    var label: some View {
        HStack {
            Text("Estimated")
            Spacer()
            MaintenanceEstimateText(model, settingsStore)
        }
    }
}

public struct MaintenanceFormSections: View {
    
    @Environment(SettingsStore.self) var settingsStore: SettingsStore

    @Bindable var model: HealthModel

    public init(_ model: HealthModel) {
        self.model = model
    }

    public var body: some View {
        Group {
            MaintenanceCalculationSection(model)
            MaintenanceEstimateSection()
                .environment(model)
        }
    }
}


#Preview {
    Text("")
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
                HealthSummary(model: MockHealthModel)
                    .environment(SettingsStore.shared)
            }
        }
}
