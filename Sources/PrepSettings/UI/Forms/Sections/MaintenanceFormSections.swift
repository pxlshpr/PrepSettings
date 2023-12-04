import SwiftUI
import PrepShared

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
