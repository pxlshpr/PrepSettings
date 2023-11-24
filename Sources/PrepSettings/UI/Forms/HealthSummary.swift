import SwiftUI
import PrepShared
import TipKit

public struct HealthSummary: View {
    
    @Environment(SettingsStore.self) var settingsStore: SettingsStore

    @Bindable var model: HealthModel
    
    public init(model: HealthModel) {
        self.model = model
    }
    
    public var body: some View {
        Form {
            dateSection
            syncAllSection
            content(for: .maintenanceEnergy)
            content(for: .age)
            content(for: .sex)
            content(for: .height)
            content(for: .weight)
            content(for: .leanBodyMass)
            dailyValuesSection
        }
        .navigationTitle("Health Details")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { toolbarContent }
    }
    
    var dateSection: some View {
        
        var date: Date { model.health.date }
        
        var footer: some View {
            Text("You are viewing the health details of a past date. Changes will not affect your current health details and will only affect the goals you had set on this day.")
        }
        
        return Group {
            if !date.isToday {
                Section(footer: footer) {
                    HStack {
                        Text("Date")
                        Spacer()
                        Text(date.adaptiveMaintenanceDateString)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
    
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button("Clear Health Details") {
                    withAnimation {
                        model.health = Health()
                        model.typesBeingSetFromHealthKit = []
                    }
                }
            } label: {
                Image(systemName: "switch.2")
            }
        }
    }
    
    var syncAllSection: some View {
//            Section {
//                TipView(tip, arrowEdge: .bottom)
//                    .listRowBackground(EmptyView())
//            }
        var section: some View {
            Section {
                HStack(alignment: .top) {
                    VStack {
                        Image(systemName: "heart.text.square")
                            .font(.system(size: 50))
                            .foregroundStyle(Color.accentColor)
                        Spacer()
                    }
                    VStack(alignment: .leading) {
                        Text("Health App")
                            .fontWeight(.semibold)
                        Text("Fill in data from the Health App and have them stay synced to any changes")
                            .font(.system(.callout))
                            .foregroundStyle(.secondary)
                        Divider()
                        Button("Fill from Health App") {
                            Task(priority: .high) {
                                try await model.setAllFromHealthKit()
                            }
                        }
                        .fontWeight(.semibold)
                        .padding(.top, 5)
                    }
                }
                .padding(.top)
            }
        }
        
        return Group {
            if model.health.doesNotHaveAnyHealthKitBasedTypesSet {
                section
            }
        }
    }
    
    func content(for type: HealthType) -> some View {
        
        @ViewBuilder
        var footer: some View {
            if let reason = type.reason {
                Text(reason)
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
            case .age:
                HealthAgeSection(model)
            case .weight:
                HealthWeightSection(model, settingsStore)
            case .height:
                HealthHeightSection(model, settingsStore)
            case .sex:
                HealthSexSection(model)
            case .leanBodyMass:
                HealthLeanBodyMassSection(model, settingsStore)
            case .pregnancyStatus:
                HealthTopRow(type: .pregnancyStatus, model: model)
            case .isSmoker:
                HealthTopRow(type: .isSmoker, model: model)
            case .maintenanceEnergy:
                Group {
                    MaintenanceFormSections(model)
                        .environment(settingsStore)
//                    Divider()
//                    Color.clear
//                        .listRowBackground(EmptyView())
//                        .listSectionSpacing(0)
                }
            default:
                EmptyView()
//                Section {
//                    link(type)
//                }
            }
        }
        
        var addSection: some View {
            @ViewBuilder
            var header: some View {
                switch type {
                case .age:   HealthBodyProfileTitle(model)
                default:        EmptyView()
                }
            }
            return Section(header: header, footer: footer) {
                addButton
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
    
    var dailyValuesSection: some View {
        var footer: some View {
            Text("Used as a criteria when choosing daily values for micronutrients.")
        }
        return Section(footer: footer) {
            if model.sexValue == .female {
                content(for: .pregnancyStatus)
            }
            if model.pregnancyStatus == nil || model.pregnancyStatus == .notPregnantOrLactating {
                content(for: .isSmoker)
            }
        }
    }
    
//    func link(_ type: HealthType) -> some View {
//        HealthLink(type: type)
//            .environment(model)
//            .environment(settingsStore)
//    }
}

#Preview {
    NavigationStack {
        HealthSummary(model: MockHealthModel)
            .environment(SettingsStore.shared)
    }
}
