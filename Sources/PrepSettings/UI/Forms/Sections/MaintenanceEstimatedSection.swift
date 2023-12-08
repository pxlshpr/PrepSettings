import SwiftUI
import PrepShared

public struct MaintenanceEstimatedSection: View {
    
    enum Route {
        case estimate
    }
    
    @Environment(SettingsStore.self) var settingsStore: SettingsStore

    @Bindable var model: HealthModel

    init(_ model: HealthModel) {
        self.model = model
    }
    
    public var body: some View {
        Section(footer: footer) {
            NavigationLink(value: Route.estimate) {
                label
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .estimate:
                    EstimatedMaintenanceForm(model)
                        .environment(settingsStore)
                }
            }
        }
    }
    
//    @ViewBuilder
    var footer: some View {
//        if model.maintenanceEnergyIsAdaptive {
//            Text("The estimate is also used when there isn't sufficient data to calculate your adaptive maintenance.")
//        Text("An estimate of your resting and active energies are added together to calculate this.")
        Text("An estimate based on your resting and active energies.")
//        }
    }
    
    var label: some View {
        HStack {
            Text("Estimated")
            Spacer()
            MaintenanceEstimateText(model, settingsStore)
        }
    }
}
