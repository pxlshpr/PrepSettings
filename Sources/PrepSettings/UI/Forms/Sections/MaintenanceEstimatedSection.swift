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
                    MaintenanceEstimateView(model)
                        .environment(settingsStore)
                }
            }
        }
    }
    
//    @ViewBuilder
    var footer: some View {
//        if model.maintenanceEnergyIsAdaptive {
            Text("This estimate is used when there isn't sufficient weight or nutrition data to make a calculation.")
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
