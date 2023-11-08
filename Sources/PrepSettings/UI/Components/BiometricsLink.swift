import SwiftUI
import PrepShared

struct BiometricLink: View {
    
    @Environment(BiometricsStore.self) var biometricsStore: BiometricsStore
    
    let type: BiometricType
    let isRequired: Bool
    
    init(type: BiometricType, isRequired: Bool = false) {
        self.type = type
        self.isRequired = isRequired
    }
    
    var body: some View {
        NavigationLink {
            Group {
                switch type {
                case .maintenanceEnergy:    MaintenanceForm(biometricsStore)
                default:                    BiometricsForm(biometricsStore, [type])
                }
            }
        } label: {
            HStack {
                Text(type.name.lowercased().capitalizingFirstLetter())
                Spacer()
                if biometrics.haveValue(for: type) {
                    biometrics.textView(for: type)
                        .foregroundStyle(.secondary)
//                }
//                if let maintenance = biometrics.maintenanceEnergy {
//                    HStack(spacing: 3) {
//                        Text(maintenance.formattedEnergy)
//                            .font(BiometricFont)
//                        Text(biometrics.energyUnit.abbreviation)
//                    }
//                    .foregroundStyle(.secondary)
                } else {
                    Text(placeholder)
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }
    
    
    var biometrics: Biometrics {
        biometricsStore.biometrics
    }
    
    var placeholder: String {
        isRequired ? "Required" : "Not set"
    }
}
