import SwiftUI
import PrepShared
import PrepSettings

//TODO: New Tasks
/// [ ] Bring in the Settings Biometrics form here too
/// [ ] Have it so that user can remove values for health data if they wish
/// [ ] Have it so that a value of 0 kg for things like weight are considered invalid and aren't saved, and are set to be empty instead
/// [ ] Now create sections for pregnancy status and smoking status
/// [ ] Add pregnancy status and smoking status to Settings Biometrics form
struct ContentView: View {
    
//    @State var settingsStore = SettingsStore.shared
    @State var biometricsStore: BiometricsStore
    
    init() {
        let biometricsStore = BiometricsStore(
            currentBiometricsHandler: Self.fetchBiometrics,
            saveHandler: Self.saveBiometrics
        )
        _biometricsStore = State(initialValue: biometricsStore)
//        SettingsStore.configure(
//            fetchHandler: Self.fetchSettings,
//            saveHandler: Self.saveSettings
//        )
    }
    
    var body: some View {
        NavigationView {
            BiometricsForm(biometricsStore, [.weight, .height])
//                .environment(settingsStore)
        }
    }
}

extension ContentView {

    static func fetchBiometrics() async throws -> Biometrics {
        let url = getDocumentsDirectory().appendingPathComponent("biometrics.json")
        do {
            let data = try Data(contentsOf: url)
            let biometrics = try JSONDecoder().decode(Biometrics.self, from: data)
            return biometrics
        } catch {
            return .init()
        }
    }
    
    static func saveBiometrics(_ biometrics: Biometrics, isCurrent: Bool) async throws {
        let url = getDocumentsDirectory().appendingPathComponent("biometrics.json")
        let json = try JSONEncoder().encode(biometrics)
        try json.write(to: url)
    }
    
//    static func fetchSettings() async throws -> Settings {
//        let url = getDocumentsDirectory().appendingPathComponent("settings.json")
//        do {
//            let data = try Data(contentsOf: url)
//            let settings = try JSONDecoder().decode(Settings.self, from: data)
//            return settings
//        } catch {
//            return .default
//        }
//    }
//    
//    static func saveSettings(_ settings: Settings) async throws {
//        let url = getDocumentsDirectory().appendingPathComponent("settings.json")
//        let json = try JSONEncoder().encode(settings)
//        try json.write(to: url)
//    }
    
    static func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

#Preview {
    ContentView()
}
