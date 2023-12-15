import SwiftUI
import PrepShared

public struct MaintenanceFormSections: View {
    
    @Environment(SettingsStore.self) var settingsStore: SettingsStore

    @Bindable var healthModel: HealthModel

    public init(_ model: HealthModel) {
        self.healthModel = model
    }

    /// [ ] Remove minus button
    /// [ ] Have estimated and "Calculated" as two separate rows
    /// [ ] Calculated should just say "Not Set" when not set
    /// [ ] Have another section with a toggle to choose between "calculated" and "adaptive" when it has been set
    public var body: some View {
        Group {
            explanationSection
            if healthModel.health.hasType(.maintenance) {
                MaintenanceAdaptiveSection(healthModel)
                MaintenanceEstimatedSection(healthModel)
                MaintenanceValueSection(healthModel)
                removeSection
            } else {
                addSection
            }
        }
    }
    
    var addSection: some View {
        Section {
            Button("Set Maintenance Energy") {
                withAnimation {
                    healthModel.add(.maintenance)
                }
            }
        }
    }
    
    var explanationSection: some View {
        Section {
            Text("Your maintenance energy (also known as your Total Daily Energy Expenditure or TDEE) is the dietary energy you would need to consume daily to maintain your weight.\n\nIt is used to create energy goals that target a desired change in your weight.\n\nYou can choose to calculate it in two ways. \"Adaptive\" compares your weight change to the energy you consumed over a specified period. \"Estimated\" uses your resting and active energies. You would find the adaptive calculation to be more accurate, especially when you have enough data.")
                .font(.callout)
        }
    }
    
    var removeSection: some View {
        Section {
            Button("Remove") {
                withAnimation {
                    healthModel.remove(.maintenance)
                }
            }
        }
    }
}


#Preview {
    Text("")
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
//                HealthSummary(model: MockHealthModel)
//                    .environment(SettingsStore.shared)
                HealthForm(MockCurrentHealthModel, [.maintenance])
                    .environment(SettingsStore.shared)
            }
        }
}
