import SwiftUI
import PrepShared
import TipKit

struct HealthBodyProfileTitle: View {
    
    @Bindable var model: HealthModel
    
    init(_ model: HealthModel) {
        self.model = model
    }
    
    @ViewBuilder
    var body: some View {
        if model.health.hasType(.maintenanceEnergy) {
            content
                .padding(.top)
        } else {
            content
        }
    }
    
    var content: some View {
        Text("Body Profile")
            .font(.title2)
            .textCase(.none)
            .foregroundStyle(Color(.label))
            .fontWeight(.bold)
    }
}

public extension Health {
    var doesNotHaveAnyHealthKitBasedTypesSet: Bool {
        restingEnergy == nil
        && activeEnergy == nil
        && age == nil
        && sex == nil
        && weight == nil
        && height == nil
        && leanBodyMass == nil
    }
}

public struct HealthSummary: View {
    
    @Bindable var model: HealthModel
    
    var tip = FetchAllFromHealthTip()
    
    public init(model: HealthModel) {
        self.model = model
    }
    
    public var body: some View {
        Form {
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

struct HealthKitErrorCell: View {
    let type: HealthType
    var body: some View {
        HStack(alignment: .top) {
//                Text("⚠️")
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundStyle(Color.accentColor)
            VStack(alignment: .leading) {
                Text(heading)
                    .fontWeight(.semibold)
                Text(message)
                    .font(.system(.callout))
                    .foregroundStyle(.secondary)
                Text(location)
                    .foregroundStyle(Color(.secondaryLabel))
                    .font(.footnote)
                    .padding(.vertical, 3)
                    .padding(.horizontal, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(.background.tertiary)
                    )
//                Divider()
                Text(secondaryMessage)
                    .font(.system(.callout))
                    .foregroundStyle(Color(.secondaryLabel))
//                Button("Open Settings") {
//                    Task {
//                        if let url = URL(string: UIApplication.openSettingsURLString) {
//                            await UIApplication.shared.open(url)
//                        }
//                    }
//                }
//                .fontWeight(.semibold)
//                .padding(.top, 5)
            }
        }
    }
    
    var heading: String {
        "Data unavailable"
    }
    
    var message: String {
        "Check that you have allowed Prep to read your \(type.abbreviation) in:"
    }
    
    var secondaryMessage: String {
        "If allowed, then there may be no \(type.abbreviation) data."
    }
    
    var location: String {
        "Settings > Privacy & Security > Health > Prep"
    }
}


#Preview {
    NavigationView {
        HealthSummary(model: MockHealthModel)
    }
}
