import SwiftUI
import PrepShared

public struct TDEEForm: View {
    
    @Bindable var model: HealthModel
    
    public init(_ model: HealthModel) {
        self.model = model
    }
    
    public var body: some View {
        form
            .navigationTitle("Maintenance Energy")
    }
    
    var health: Health {
        model.health
    }
    
    var form: some View {
        Form {
            maintenanceSection
            symbol("=")
            RestingSection(model: model)
            symbol("+")
            ActiveSection(model: model)
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
            if let requiredString = health.tdeeRequiredString {
                Text(requiredString)
                    .foregroundStyle(Color(.tertiaryLabel))
            } else {
                if let maintenanceEnergy = health.maintenanceEnergy {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(maintenanceEnergy.formattedEnergy)
                            .animation(.default, value: maintenanceEnergy)
                            .contentTransition(.numericText(value: maintenanceEnergy))
                            .font(.system(.largeTitle, design: .monospaced, weight: .bold))
                            .foregroundStyle(.secondary)
                        Text(health.energyUnit.abbreviation)
                            .foregroundStyle(Color(.tertiaryLabel))
                            .font(.system(.body, design: .rounded, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
    }
}
