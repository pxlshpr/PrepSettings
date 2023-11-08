import Foundation

public let DocumentsBasedHealthModel = HealthModel(
    fetchCurrentHealthHandler: fetchHealthFromDocuments,
    saveHandler: saveHealthInDocuments
)

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
    
//func fetchSettings() async throws -> Settings {
//    let url = getDocumentsDirectory().appendingPathComponent("settings.json")
//    do {
//        let data = try Data(contentsOf: url)
//        let settings = try JSONDecoder().decode(Settings.self, from: data)
//        return settings
//    } catch {
//        return .default
//    }
//}
//
//func saveSettings(_ settings: Settings) async throws {
//    let url = getDocumentsDirectory().appendingPathComponent("settings.json")
//    let json = try JSONEncoder().encode(settings)
//    try json.write(to: url)
//}
    
func getDocumentsDirectory() -> URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
}
