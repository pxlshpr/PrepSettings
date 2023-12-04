import SwiftUI
import PrepShared

public struct HealthForm: View {
    
    @Environment(SettingsStore.self) var settingsStore: SettingsStore
    @Bindable var model: HealthModel
    @FocusState var focusedType: HealthType?

    let types: [HealthType]
    let title: String
    
    public init(_ model: HealthModel, _ types: [HealthType]? = nil) {
        self.model = model
        self.types = types ?? model.health.restingEnergyEquation.params
        self.title = if let types, let type = types.first, types.count == 1 {
            type.name
        } else {
            "Health Details"
        }
    }
    
    public var body: some View {
        Form {
            ForEach(types, id: \.self) {
                content(for: $0)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        .onChange(of: focusedType, model.focusedTypeChanged)
        .toolbar { keyboardToolbarContent }
    }
    
    var keyboardToolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            HStack {
                Spacer()
                Button("Done") {
                    focusedType = nil
                }
                .fontWeight(.semibold)
            }
        }
    }

    func content(for type: HealthType) -> some View {
        var addSection: some View {
            @ViewBuilder
            var footer: some View {
                if let reason = type.reason {
                    Text(reason)
                }
            }

            return Section(footer: footer) {
                addButton
            }
        }
        
        var addButton: some View {
            Button("Set \(type.nameWhenSetting)") {
                withAnimation {
                    model.add(type)
                }
            }
        }

        @ViewBuilder
        var section: some View {
            switch type {
            case .sex:
                HealthSexSection(model)
            case .age:
                HealthAgeSection(model, $focusedType)
            case .weight:
                HealthWeightSections(model, settingsStore, $focusedType)
            case .leanBodyMass:
                HealthLeanBodyMassSection(model, settingsStore, $focusedType)
            case .height:
                HealthHeightSection(model, settingsStore, $focusedType)
            case .pregnancyStatus:
                HealthTopRow(type: .pregnancyStatus, model: model)
            case .isSmoker:
                HealthTopRow(type: .isSmoker, model: model)
            case .maintenanceEnergy:
                MaintenanceFormSections(model)
                    .environment(settingsStore)
            default:
                EmptyView()
            }
        }

        return Group {
            if model.health.hasType(type) {
                section
            } else {
                addSection
            }
        }
    }
}

#Preview {
    NavigationStack {
        HealthForm(MockHealthModel, [.leanBodyMass])
            .environment(SettingsStore.shared)
            .onAppear {
                SettingsStore.configureAsMock()
            }
    }
}
