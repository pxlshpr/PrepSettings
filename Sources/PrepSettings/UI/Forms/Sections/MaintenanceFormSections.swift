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
            /// Using this instead of `NavigationLink(destination:label:)` as that results in the offset bug mentioned here https://www.reddit.com/r/SwiftUI/comments/17pqj3d/on_ios_17_how_to_work_around_list_offset_jumping/
            NavigationLink(value: Route.maintenance) {
                label
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .maintenance:
                    MaintenanceEstimateForm(model)
                        .environment(settingsStore)
                }
            }
        }
    }

    var maintenanceSection: some View {
        func emptyContent(_ message: String) -> some View {
            Text(message)
                .foregroundStyle(.tertiary)
        }
        
        func valueContent(_ value: Double) -> some View {
            HStack(alignment: .firstTextBaseline, spacing: UnitSpacing) {
                Text(value.formattedEnergy)
                    .animation(.default, value: value)
                    .contentTransition(.numericText(value: value))
                    .font(NumberFont)
                    .foregroundStyle(.secondary)
                Text(settingsStore.energyUnit.abbreviation)
                    .foregroundStyle(.secondary)
                    .font(.system(.body, design: .default, weight: .semibold))
            }
//            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        
        var adaptiveRow: some View {
            HStack {
                Text("Use Adaptive Calculation")
                    .layoutPriority(1)
                Spacer()
                Toggle("", isOn: $model.maintenanceEnergyIsAdaptive)
            }
        }
        
        var footer: some View {
//            Text("Your \(HealthType.maintenanceEnergy.abbreviation) is used in energy goals, when targeting a desired weight change.")
            Text(HealthType.maintenanceEnergy.reason!)
        }

        var adaptiveFooter: some View {
            Text("Adaptively calculate your \(HealthType.maintenanceEnergy.abbreviation) based on your weight change and dietary energy over the prior week. [Learn More.](https://example.com)")
        }

        return Group {
            Section(footer: footer) {
                MaintenanceEnergyRow(model)
                    .environment(settingsStore)
            }
            Section(footer: adaptiveFooter) {
                adaptiveRow
            }
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
