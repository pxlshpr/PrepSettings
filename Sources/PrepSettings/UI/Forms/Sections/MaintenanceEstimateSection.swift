import SwiftUI
import PrepShared

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
