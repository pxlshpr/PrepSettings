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
//            fetchAllFromHealthSection
            Section {
                TipView(tip, arrowEdge: .bottom)
                    .listRowBackground(EmptyView())
            }
            .listSectionSpacing(.compact)
            section(for: .maintenanceEnergy)
            section(for: .weight)
            section(for: .height)
            
            section(for: .age)
            section(for: .sex)
            section(for: .leanBodyMass)

            dailyValuesSection

//            ForEach(HealthType.summaryTypes, id: \.self) {
//                section(for: $0)
//            }
        }
        .navigationTitle("Health Details")
        .navigationBarTitleDisplayMode(.large)
    }
    
    func section(for type: HealthType) -> some View {
        
        @ViewBuilder
        var footer: some View {
            if let reason = type.reason {
                Text(reason)
            }
        }
        
        var addButton: some View {
            Button("Set \(type.name)") {
                withAnimation {
                    model.add(type)
                }
            }
        }
        
        @ViewBuilder
        var section: some View {
            switch type {
            case .age:
                HealthAgeSection(model: model)
            case .weight:
                HealthWeightSection(model: model)
            case .height:
                HealthHeightSection(model: model)
            case .sex:
                HealthSexSection(model: model)
            case .leanBodyMass:
                HealthLeanBodyMassSection(model: model)
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
        return Section(header: header, footer: footer) {
            if model.sexValue == .female {
                link(.pregnancyStatus)
            }
            if model.pregnancyStatus == nil || model.pregnancyStatus == .notPregnantOrLactating {
                link(.isSmoker)
            }
        }
    }
    
    func link(_ type: HealthType) -> some View {
        HealthLink(type: type)
            .environment(model)
    }
    
    @ViewBuilder
    var fetchAllFromHealthSection: some View {
        if model.health.healthSourcedCount > 1 {
            Section {
                Button("Set all from Health app") {
                    Task(priority: .userInitiated) {
                        try await model.setAllFromHealthKit()
                    }
                }
            }
        }
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
