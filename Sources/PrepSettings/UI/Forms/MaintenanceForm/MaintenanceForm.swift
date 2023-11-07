import SwiftUI
import PrepShared

public struct MaintenanceForm: View {
    
    @Bindable var biometricsStore: BiometricsStore
    
    public init(_ biometricsStore: BiometricsStore) {
        self.biometricsStore = biometricsStore
    }
    
    public var body: some View {
        form
            .navigationTitle("Maintenance Energy")
    }
    
    var biometrics: Biometrics {
        biometricsStore.biometrics
    }
    
    var form: some View {
        Form {
            maintenanceSection
            symbol("=")
            RestingSection(biometricsStore: biometricsStore)
            symbol("+")
            ActiveSection(biometricsStore: biometricsStore)
        }
        .scrollDismissesKeyboard(.interactively)
    }
    
    func symbol(_ string: String) -> some View {
        Text(string)
            .frame(maxWidth: .infinity, alignment: .center)
            .font(.system(.title, design: .rounded, weight: .semibold))
            .foregroundColor(.secondary)
            .listRowBackground(EmptyView())
    }
    
    var maintenanceSection: some View {
        Section {
            if let requiredString = biometrics.tdeeRequiredString {
                Text(requiredString)
                    .foregroundStyle(Color(.tertiaryLabel))
            } else {
                if let maintenanceEnergy = biometrics.maintenanceEnergy {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(maintenanceEnergy.formattedEnergy)
                            .animation(.default, value: maintenanceEnergy)
                            .contentTransition(.numericText(value: maintenanceEnergy))
                            .font(.system(.largeTitle, design: .monospaced, weight: .bold))
                            .foregroundStyle(.secondary)
                        Text(biometrics.energyUnit.abbreviation)
                            .foregroundStyle(Color(.tertiaryLabel))
                            .font(.system(.body, design: .rounded, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
    }
}
