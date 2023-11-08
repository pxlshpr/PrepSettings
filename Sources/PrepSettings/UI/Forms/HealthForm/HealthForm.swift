import SwiftUI
import PrepShared

public struct HealthForm: View {
    
    @Bindable var model: HealthModel

    let types: [HealthType]
    let title: String
    
    public init(_ model: HealthModel, _ types: [HealthType]? = nil) {
        self.model = model
        self.types = types ?? model.health.restingEnergyEquation.params
        self.title = if let types, let type = types.first, types.count == 1 {
            type.name
        } else {
            "Health Data"
        }
    }
    
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
    func section(for param: HealthType) -> some View {
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
