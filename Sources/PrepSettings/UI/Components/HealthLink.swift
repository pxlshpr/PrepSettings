import SwiftUI
import PrepShared

public struct HealthLink: View {
    
    @Environment(HealthModel.self) var model: HealthModel
    
    let type: HealthType
    let isRequired: Bool
    
    public init(type: HealthType, isRequired: Bool = false) {
        self.type = type
        self.isRequired = isRequired
    }
    
    public var body: some View {
        NavigationLink {
            Group {
                switch type {
                case .maintenanceEnergy:    MaintenanceForm(model)
                default:                    HealthForm(model, [type])
                }
            }
        } label: {
            HStack {
                Text(type.name.lowercased().capitalizingFirstLetter())
                Spacer()
                if health.haveValue(for: type) {
                    health.textView(for: type)
                        .foregroundStyle(.secondary)
//                }
//                if let maintenance = health.maintenanceEnergy {
//                    HStack(spacing: 3) {
//                        Text(maintenance.formattedEnergy)
//                            .font(HealthFont)
//                        Text(health.energyUnit.abbreviation)
//                    }
//                    .foregroundStyle(.secondary)
                } else {
                    Text(placeholder)
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }
    
    
    var health: Health {
        model.health
    }
    
    var placeholder: String {
        isRequired ? "Required" : "Not set"
    }
}
