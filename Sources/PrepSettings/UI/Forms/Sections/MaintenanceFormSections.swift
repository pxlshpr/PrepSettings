import SwiftUI
import PrepShared

public struct MaintenanceFormSections: View {
    
    enum Route {
        case maintenance
    }
    
    @Environment(SettingsStore.self) var settingsStore: SettingsStore

    @Bindable var model: HealthModel

    public init(_ model: HealthModel) {
        self.model = model
    }

    public var body: some View {
        Group {
            maintenanceSection
            estimateSection
        }
    }
    
    var health: Health {
        model.health
    }
    
    var estimateSection: some View {
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
        
        return Section(footer: footer) {
            NavigationLink(value: Route.maintenance) {
                label
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .maintenance:
                    MaintenanceEstimateView(model)
                        .environment(settingsStore)
                }
            }
        }
    }

    var maintenanceSection: some View {
        
        var calculateSection: some View {
            var footer: some View {
//                Text("Adaptively calculate your \(HealthType.maintenanceEnergy.abbreviation) based on your weight change and dietary energy over the prior week. [Learn More.](https://example.com)")
                Text("Your weight change is comapred to the dietary energy you consumed to determine your true maintenance. [Learn More.](https://example.com)")
            }

            return Section(footer: footer) {
                HStack {
                    Text("Calculate True Maintenance")
//                    Text("Use Adaptive Calculation")
                        .layoutPriority(1)
                    Spacer()
                    Toggle("", isOn: $model.maintenanceEnergyIsAdaptive)
                }
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

        return Group {
            maintenanceSection
            calculateSection
        }
    }
    
//    var maintenanceSection_: some View {
//        var header: some View {
//            HStack(alignment: .lastTextBaseline) {
//                HealthHeaderText("Maintenance Energy", isLarge: true)
//                Spacer()
//                Button("Remove") {
//                    withAnimation {
//                        model.remove(.maintenanceEnergy)
//                    }
//                }
//                .textCase(.none)
//            }
//        }
//        
//        var footer: some View {
//            Text(HealthType.maintenanceEnergy.reason!)
//        }
//        
//        return Section(header: header) {
//            if let requiredString = health.tdeeRequiredString {
//                Text(requiredString)
//                    .foregroundStyle(Color(.tertiaryLabel))
//            } else {
//                if let maintenanceEnergy = health.estimatedMaintenance {
//                    HStack(alignment: .firstTextBaseline, spacing: 2) {
//                        Text(maintenanceEnergy.formattedEnergy)
//                            .animation(.default, value: maintenanceEnergy)
//                            .contentTransition(.numericText(value: maintenanceEnergy))
//                            .font(.system(.largeTitle, design: .monospaced, weight: .bold))
//                            .foregroundStyle(.secondary)
//                        Text(health.energyUnit.abbreviation)
//                            .foregroundStyle(Color(.tertiaryLabel))
//                            .font(.system(.body, design: .rounded, weight: .semibold))
//                    }
//                    .frame(maxWidth: .infinity, alignment: .trailing)
//                }
//            }
//        }
//    }
}
