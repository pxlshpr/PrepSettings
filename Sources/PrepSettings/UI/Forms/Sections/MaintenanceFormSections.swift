import SwiftUI
import PrepShared

public struct MaintenanceFormSections: View {
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
                Text("Used when there isn't sufficient weight or nutrition data to make a calculation.")
            }
        }
        
        return Section(footer: footer) {
            NavigationLink {
                MaintenanceEstimateForm(model)
            } label: {
                HStack {
                    Text("Estimated")
                    Spacer()
                    MaintenanceEstimateText(model)
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
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value.formattedEnergy)
                    .animation(.default, value: value)
                    .contentTransition(.numericText(value: value))
                    .font(.system(.body, design: .monospaced, weight: .bold))
                    .foregroundStyle(.secondary)
                Text(health.energyUnit.abbreviation)
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
