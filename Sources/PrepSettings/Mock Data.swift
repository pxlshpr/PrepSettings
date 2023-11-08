import Foundation

public let MockHealthModel = HealthModel(
    fetchCurrentHealthHandler: fetchHealthFromDocuments,
    saveHandler: saveHealthInDocuments
)

public extension SettingsStore {
    /// Saves and fetches from a `.json` file encoded/decoded in the documents directory
    func configureAsMock() {
        SettingsStore.configure(
            fetchHandler: fetchSettingsFromDocuments,
            saveHandler: saveSettingsInDocuments
        )
    }
}

//MARK: - Private

func fetchHealthFromDocuments() async throws -> Health {
    let url = getDocumentsDirectory().appendingPathComponent("health.json")
    do {
        let data = try Data(contentsOf: url)
        let health = try JSONDecoder().decode(Health.self, from: data)
        return health
    } catch {
        return .init()
    }
}

func saveHealthInDocuments(_ health: Health, isCurrent: Bool) async throws {
    let url = getDocumentsDirectory().appendingPathComponent("health.json")
    let json = try JSONEncoder().encode(health)
    try json.write(to: url)
}
    
func fetchSettingsFromDocuments() async throws -> Settings {
    let url = getDocumentsDirectory().appendingPathComponent("settings.json")
    do {
        let data = try Data(contentsOf: url)
        let settings = try JSONDecoder().decode(Settings.self, from: data)
        return settings
    } catch {
        return .default
    }
}

func saveSettingsInDocuments(_ settings: Settings) async throws {
    let url = getDocumentsDirectory().appendingPathComponent("settings.json")
    let json = try JSONEncoder().encode(settings)
    try json.write(to: url)
}
    
func getDocumentsDirectory() -> URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
}
