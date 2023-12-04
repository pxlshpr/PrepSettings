import SwiftUI
import PrepShared

public struct MaintenanceEstimateView: View {
    
    @Environment(SettingsStore.self) var settingsStore: SettingsStore
    @Bindable var model: HealthModel
    @State var hasAppeared = false
    @FocusState var focusedType: HealthType?
    
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
//        .navigationTitle("Maintenance Energy")
//        .navigationTitle("Estimate")
        .navigationTitle("Estimated Maintenance")
//        .navigationBarTitleDisplayMode(.large)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: focusedType, model.focusedTypeChanged)
    }
    
    var form: some View {
        Form {
            HealthLink(type: .restingEnergy)
                .environment(settingsStore)
                .environment(model)
//            RestingEnergySections(
//                model: model,
//                settingsStore: settingsStore,
//                focusedType: $focusedType
//            )
//            Section {
//                symbol("+")
//            }
//            .listSectionSpacing(0)
            HealthLink(type: .activeEnergy)
                .environment(settingsStore)
                .environment(model)
//            ActiveEnergySection(
//                model: model,
//                settingsStore: settingsStore,
//                focusedType: $focusedType
//            )
//            Section {
//                symbol("=")
//            }
//            .listSectionSpacing(0)
            estimateSection
        }
        .toolbar { keyboardToolbarContent }
    }
    
    func appeared() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            hasAppeared = true
        }
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
    
    func symbol(_ string: String) -> some View {
        Text(string)
            .frame(maxWidth: .infinity, alignment: .center)
            .font(.system(.title, design: .rounded, weight: .semibold))
            .foregroundColor(.secondary)
            .listRowBackground(EmptyView())
    }
    
    var estimateSection: some View {
        Section {
            VStack {
//                HStack {
//                    Text("Estimated")
//                        .fontWeight(.semibold)
//                    Spacer()
//                }
                HStack {
                    if model.health.tdeeRequiredString == nil, model.health.estimatedMaintenanceInKcal != nil 
                    {
                        Image(systemName: "equal")
                            .foregroundStyle(.secondary)
                            .font(.title2)
                            .fontWeight(.heavy)
                    }
                    Spacer()
                    if let string = model.health.tdeeRequiredString {
                        Text(string)
                            .foregroundStyle(Color(.tertiaryLabel))
                    } else if let value = model.health.estimatedMaintenance(in: settingsStore.energyUnit) {
                        HStack(alignment: .firstTextBaseline, spacing: UnitSpacing) {
                            Text(value.formattedEnergy)
                                .animation(.default, value: value)
                                .contentTransition(.numericText(value: value))
                                .font(.system(.largeTitle, design: .monospaced, weight: .bold))
                            Text("\(settingsStore.energyUnit.abbreviation) / day")
                                .foregroundStyle(.secondary)
                                .font(.system(.body, design: .default, weight: .semibold))
                        }
                        .multilineTextAlignment(.trailing)
                    } else {
                        EmptyView()
                    }
                }
            }
        }
    }
}

struct HealthLink: View {
    
    @Environment(SettingsStore.self) var settingsStore: SettingsStore
    @Environment(HealthModel.self) var model: HealthModel
    let type: HealthType
    
    var body: some View {
        NavigationLink(value: type) {
            HStack {
                Text(type.name)
                Spacer()
                if let string = model.health.summaryDetail(for: type) {
                    Text(string)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Not set")
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .navigationDestination(for: HealthType.self) { type in
            HealthForm(model, [type])
                .environment(settingsStore)
        }
    }
}

#Preview {
    Text("")
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
                MaintenanceEstimateView(MockHealthModel)
                    .environment(SettingsStore.shared)
            }
        }
}
