import SwiftUI
import PrepShared

public struct HealthSummary: View {
    
    @Bindable var model: HealthModel
    
    public init(model: HealthModel) {
        self.model = model
    }
    
    public var body: some View {
        Form {
            Section {
                link(.maintenanceEnergy)
            }
            Section {
                link(.age)
                link(.sex)
                link(.height)
                link(.weight)
                link(.leanBodyMass)
            }
            fetchAllFromHealthSection
        }
        .navigationTitle("Health Data")
        .navigationBarTitleDisplayMode(.large)
    }
    
    func link(_ type: HealthType) -> some View {
        HealthLink(type: type)
            .environment(model)
    }
    
    @ViewBuilder
    var fetchAllFromHealthSection: some View {
        if model.health.healthSourcedCount > 1 {
            Section {
                Button("Set all from Health app") {
                    Task(priority: .userInitiated) {
                        try await model.setAllFromHealthKit()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        HealthSummary(model: MockHealthModel)
    }
}
