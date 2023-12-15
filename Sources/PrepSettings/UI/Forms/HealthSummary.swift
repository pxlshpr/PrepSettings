import SwiftUI
import PrepShared
import TipKit

public struct HealthSummary: View {
    
    @Environment(SettingsStore.self) var settingsStore: SettingsStore
    @Environment(\.dismiss) var dismiss
    @Bindable var model: HealthModel
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
    }

    var form: some View {
        Form {
            dateSection
            syncAllSection
            ForEach(HealthType.summaryTypes, id: \.self) {
                content(for: $0)
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
                    }
                }
            }
        }
    }
    
    var toolbarContent: some ToolbarContent {
        var pastContent: some ToolbarContent {
            Group {
                ToolbarItem(placement: .topBarTrailing) {
                    if model.isEditing {
                        Button("Done") {
                            
                        }
                        .fontWeight(.semibold)
                    } else {
                        Button("Edit") {
                            
                        }
                        .fontWeight(.semibold)
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        
        var currentContent: some ToolbarContent {
            Group {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        
        return Group {
            if model.isCurrent {
                currentContent
            } else {
                pastContent
            }
        }
    }
    
    var syncAllSection: some View {
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
                Text("Enable seamless syncing of your health data with Apple Health. Your goals will automatically adjust to reflect any changes.")
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
    }
}

#Preview {
    Text("")
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
                HealthSummary(model: MockCurrentHealthModel)
                    .environment(SettingsStore.shared)
            }
        }
}
