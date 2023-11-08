import SwiftUI
import PrepShared

public struct BiometricsSummary: View {
    
    @Bindable var biometricsStore: BiometricsStore
    
    public init(biometricsStore: BiometricsStore) {
        self.biometricsStore = biometricsStore
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
    
    func link(_ type: BiometricType) -> some View {
        BiometricLink(type: type)
            .environment(biometricsStore)
    }
    
    @ViewBuilder
    var fetchAllFromHealthSection: some View {
        if biometricsStore.biometrics.healthSourcedCount > 1 {
            Section {
                Button("Set all from Health app") {
                    Task(priority: .userInitiated) {
                        try await biometricsStore.setAllFromHealth()
                    }
                }
            }
        }
    }
}
