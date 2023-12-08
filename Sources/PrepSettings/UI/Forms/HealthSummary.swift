import SwiftUI
import PrepShared
import TipKit

public struct HealthSummary: View {
    
    @Environment(SettingsStore.self) var settingsStore: SettingsStore
    @Bindable var model: HealthModel
    @FocusState var focusedType: HealthType?
    @State var hasAppeared = false

    public init(model: HealthModel) {
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
        .navigationTitle("Health Details")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { toolbarContent }
        .onAppear(perform: appeared)
        .onChange(of: focusedType, model.focusedTypeChanged)
    }

    var form: some View {
        Form {
            dateSection
            syncAllSection
            ForEach(HealthType.summaryTypes, id: \.self) {
                content(for: $0)
            }
//            dailyValuesSection
        }
    }
    
    var form_: some View {
        Form {
            dateSection
            syncAllSection
            content(for: .maintenance)
            content(for: .age)
            content(for: .sex)
            content(for: .height)
            content(for: .weight)
            content(for: .leanBodyMass)
            dailyValuesSection
        }
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

    func appeared() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            hasAppeared = true
        }
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
            
            var syncButton: some View {
                Button("Sync Health Details") {
                    Task(priority: .high) {
                        try await model.setAllFromHealthKit()
                    }
                }
                .foregroundStyle(.white)
                .fontWeight(.bold)
                .padding(.top, 5)
                .buttonStyle(.plain)
            }
            
            var skipButton: some View {
                Button("Not now") {
                    withAnimation {
                        model.health.skipSyncAll = true
                    }
                }
                .foregroundStyle(.white)
                .padding(.top, 5)
                .buttonStyle(.plain)
            }
            
            var appleHealthImage: some View {
                Image(packageResource: "AppleHealthIcon", ofType: "png")
                    .resizable()
                    .frame(width: 50, height: 50)
            }
            
            var title: some View {
                Text("Apple Health")
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
            }
            
            var message: some View {
//                Text("Automatically sync your health details with Apple Health. Any goals based on them will automatically update to changes.")
                Text("Enable seamless syncing of your health data with Apple Health. Your personalized health goals will automatically adjust to reflect any changes in your health data.")
                            .font(.system(.callout))
                            .foregroundStyle(.white)
                            .opacity(0.8)
            }
            
            var divider: some View {
                Divider()
                    .overlay(Color.white)
                    .opacity(0.6)
            }
            
            var background: some View {
                Rectangle().fill(Color.accentColor.gradient)
            }
            
            return Section {
                HStack(alignment: .top) {
                    VStack {
                        appleHealthImage
                        Spacer()
                    }
                    VStack(alignment: .leading) {
                        message
                        divider
                        syncButton
                        skipButton
                    }
                }
                .padding(.top)
            }
            .listRowBackground(background)
        }
        
        return Group {
            if model.health.shouldShowSyncAllTip {
                section
            }
        }
    }

    func content(for type: HealthType) -> some View {
        HealthLink(type: type)
            .environment(settingsStore)
            .environment(model)
//        NavigationLink(value: type) {
//            HStack {
//                Text(type.name)
//                Spacer()
//                if let string = model.health.summaryDetail(for: type) {
//                    Text(string)
//                        .foregroundStyle(.secondary)
//                } else {
//                    Text("Not Set")
//                        .foregroundStyle(.tertiary)
//                }
//            }
//        }
//        .navigationDestination(for: HealthType.self) { type in
//            HealthForm(model, [type])
//                .environment(settingsStore)
//        }
    }
    
    func content_(for type: HealthType) -> some View {
        
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
                HealthAgeSection(model, $focusedType)
            case .weight:
                WeightSections(
                    healthModel: model,
                    settingsStore: settingsStore,
                    focusedType: $focusedType
                )
            case .height:
                HealthHeightSection(model, settingsStore, $focusedType)
            case .sex:
                HealthSexSection(model)
            case .leanBodyMass:
                HealthLeanBodyMassSection(model, settingsStore, $focusedType)
            case .pregnancyStatus:
                HealthTopRow(type: .pregnancyStatus, model: model)
            case .isSmoker:
                HealthTopRow(type: .isSmoker, model: model)
            case .maintenance:
                MaintenanceFormSections(model)
                    .environment(settingsStore)
            default:
                EmptyView()
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
}

#Preview {
    Text("")
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
                HealthSummary(model: MockHealthModel)
                    .environment(SettingsStore.shared)
            }
        }
}
