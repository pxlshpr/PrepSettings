import SwiftUI
import PrepShared

public struct MaintenanceFormSections: View {
    
    @Environment(SettingsStore.self) var settingsStore: SettingsStore

    @Bindable var model: HealthModel

    public init(_ model: HealthModel) {
        self.model = model
    }

    /// [ ] Remove minus button
    /// [ ] Have estimated and "Calculated" as two separate rows
    /// [ ] Calculated should just say "Not set" when not set
    /// [ ] Have another section with a toggle to choose between "calculated" and "adaptive" when it has been set
    public var body: some View {
        Group {
            MaintenanceAdaptiveSection(model)
            MaintenanceEstimatedSection(model)
            MaintenanceValueSection(model)
            removeSection
        }
    }
    
    var removeSection: some View {
        Section {
            Button("Remove") {
                withAnimation {
                    model.remove(.maintenance)
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
                HealthForm(MockHealthModel, [.maintenance])
                    .environment(SettingsStore.shared)
            }
        }
}
