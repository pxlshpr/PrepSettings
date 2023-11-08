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
    
//    @State var settingsStore = SettingsStore.shared
    @State var model: HealthModel = DocumentsBasedHealthModel
    
    init() {
//        SettingsStore.configure(
//            fetchHandler: Self.fetchSettings,
//            saveHandler: Self.saveSettings
//        )
    }
    
    var body: some View {
        NavigationView {
            HealthSummary(model: model)
//            HealthForm(model, [.weight, .height])
//                .environment(settingsStore)
        }
    }
}

#Preview {
    ContentView()
}
