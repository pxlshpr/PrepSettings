import SwiftUI
import PrepShared
import PrepSettings

//TODO: New Tasks
/// [ ] Bring in the Settings Health form here too
/// [ ] Have it so that user can remove values for health data if they wish
/// [ ] Have it so that a value of 0 kg for things like weight are considered invalid and aren't saved, and are set to be empty instead
/// [ ] Now create sections for pregnancy status and smoking status
/// [ ] Add pregnancy status and smoking status to Settings Health form
struct ContentView: View {
    
    @State var currentHealthModel: HealthModel = MockCurrentHealthModel
    @State var pastHealthModel: HealthModel

    @State var settingsStore: SettingsStore = SettingsStore.shared
    
    @State var showingCurrentHealthDetails = false
    @State var showingPastHealthDetails = false
    
    init() {
        let healthDetails: HealthDetails = fetchFromBackend(.pastHealthDetails)
        let healthModel = HealthModel(
            delegate: MockPastHealthModelDelegate(),
            health: healthDetails
        )
        _pastHealthModel = State(initialValue: healthModel)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Button("Current Health Details") {
                    showingCurrentHealthDetails = true
                }
                Button("Past Health Details") {
                    showingPastHealthDetails = true
                }
            }
        }
        .sheet(isPresented: $showingCurrentHealthDetails) { currentHealthSummary }
        .sheet(isPresented: $showingPastHealthDetails) { pastHealthSummary }
        .onAppear {
            SettingsStore.configureAsMock()
        }
    }
    
    var currentHealthSummary: some View {
        NavigationStack {
            HealthSummary(model: currentHealthModel)
                .environment(settingsStore)
        }
    }
    
    var pastHealthSummary: some View {
        NavigationStack {
            HealthSummary(model: pastHealthModel)
                .environment(settingsStore)
        }
    }
}

#Preview {
    ContentView()
}
