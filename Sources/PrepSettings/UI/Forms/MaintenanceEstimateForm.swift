import SwiftUI
import PrepShared

public struct MaintenanceEstimateForm: View {
    
    @Environment(SettingsStore.self) var settingsStore: SettingsStore
    @Bindable var model: HealthModel
    @State var hasAppeared = false

    public init(_ model: HealthModel) {
        self.model = model
    }
    
    public var body: some View {
        Group {
            if hasAppeared {
                form
            } else {
                Color.clear
            }
        }
        .onAppear(perform: appeared)
        .navigationTitle("Maintenance Energy")
        .navigationBarTitleDisplayMode(.large)
    }
    
    func appeared() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            hasAppeared = true
        }
    }

    var form: some View {
        Form {
            estimateSection
            symbol("=")
            RestingEnergySection(
                model: model,
                settingsStore: settingsStore
            )
            symbol("+")
            ActiveEnergySection(
                model: model,
                settingsStore: settingsStore
            )
        }
    }
    
    func symbol(_ string: String) -> some View {
        Text(string)
            .frame(maxWidth: .infinity, alignment: .center)
            .font(.system(.title, design: .rounded, weight: .semibold))
            .foregroundColor(.secondary)
            .listRowBackground(EmptyView())
    }
    
    var estimateSection: some View {
        Section {
            HStack {
                Text("Estimated")
                Spacer()
                MaintenanceEstimateText(model, settingsStore)
            }
        }
    }
}
