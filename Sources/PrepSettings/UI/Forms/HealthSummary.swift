import SwiftUI
import PrepShared
import TipKit

public struct HealthSummary: View {
    
    @Bindable var model: HealthModel
    
    var tip = FetchAllFromHealthTip()
    
    public init(model: HealthModel) {
        self.model = model
    }
    
    public var body: some View {
        Form {
//            syncAllSection
            content(for: .maintenanceEnergy)
            content(for: .weight)
            content(for: .height)
            content(for: .age)
            content(for: .sex)
            content(for: .leanBodyMass)
            dailyValuesSection

        }
        .navigationTitle("Health Details")
        .navigationBarTitleDisplayMode(.large)
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
                        Text("Health App data")
                            .fontWeight(.semibold)
                        Text("Use your data from the Health App and have them stay synced to any changes")
                            .font(.system(.callout))
                            .foregroundStyle(.secondary)
                        Divider()
                        Button("Use Health App") {
                            Task(priority: .userInitiated) {
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
            if model.health.healthSourcedCount > 1 {
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
                HealthWeightSection(model)
            case .height:
                HealthHeightSection(model)
            case .sex:
                HealthSexSection(model)
            case .leanBodyMass:
                HealthLeanBodyMassSection(model)
            case .pregnancyStatus:
                HealthTopRow(type: .pregnancyStatus, model: model)
            case .isSmoker:
                HealthTopRow(type: .isSmoker, model: model)
            case .maintenanceEnergy:
                Group {
                    TDEEFormSections(model)
//                    Divider()
//                    Color.clear
//                        .listRowBackground(EmptyView())
//                        .listSectionSpacing(0)
                }
            default:
                Section {
                    link(type)
                }
            }
        }
        
        return Group {
            if model.health.hasType(type) {
                section
            } else {
                Section(footer: footer) {
                    addButton
                }
            }
        }
    }
    
    var dailyValuesSection: some View {
        var header: some View {
            Text("Others")
                .font(.title2)
                .textCase(.none)
                .foregroundStyle(Color(.label))
                .fontWeight(.bold)
        }
        var footer: some View {
            Text("Used to pick daily values for micronutrients.")
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
    
    func link(_ type: HealthType) -> some View {
        HealthLink(type: type)
            .environment(model)
    }
}

struct FetchAllFromHealthTip: Tip {
    var title: Text {
        Text("Health App data")
    }
    var message: Text? {
        Text("Use your data from the Health App and have them stay synced to any changes.")
    }
    var image: Image? {
        Image(systemName: "heart.text.square")
    }
    
    var actions: [Action] {
        [
            Tip.Action(
                id: "sync-all",
                title: "Use Health App"
            )
        ]
    }
    
    var options: [TipOption] {
        [
            Tip.MaxDisplayCount(1),
        ]
    }
}

#Preview {
    NavigationView {
        HealthSummary(model: MockHealthModel)
    }
    .task {
        Tips.showAllTipsForTesting()
        try? Tips.configure()
    }
}
