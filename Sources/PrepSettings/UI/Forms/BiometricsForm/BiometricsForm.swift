import SwiftUI
import PrepShared

public struct BiometricsForm: View {
    
    @Bindable var biometricsStore: BiometricsStore

    let types: [BiometricType]
    let title: String
    
    public init(_ biometricsStore: BiometricsStore, _ types: [BiometricType]? = nil) {
        self.biometricsStore = biometricsStore
        self.types = types ?? biometricsStore.biometrics.restingEnergyEquation.params
        self.title = if let types, let type = types.first, types.count == 1 {
            type.name
        } else {
            "Health Data"
        }
    }
    
//    var biometrics: Biometrics {
//        biometricsStore.biometrics
//    }
    
    public var body: some View {
        Form {
            ForEach(types, id: \.self) {
                section(for: $0)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
    }
    
    @ViewBuilder
    func section(for param: BiometricType) -> some View {
        switch param {
        case .sex:
            sexSection
        case .age:
            ageSection
        case .weight:
            weightSection
        case .leanBodyMass:
            leanBodyMassSection
        case .height:
            heightSection
        default:
            EmptyView()
        }
    }
}
