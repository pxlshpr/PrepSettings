import Foundation

public let MockHealthModel = HealthModel(
    delegate: MockHealthDelegate(),
    fetchCurrentHealthHandler: fetchHealthFromDocuments
//    saveHandler: saveHealthInDocuments
)

struct MockHealthDelegate: HealthModelDelegate {
    func saveHealth(_ health: Health, isCurrent: Bool) async throws {
        try saveHealthInDocuments(health, isCurrent: isCurrent)
    }
    
    func maintenanceData(for dateRange: ClosedRange<Date>) async throws -> [Date : (weightInKg: Double?, dietaryEnergyInKcal: Double?)] {
        [:]
    }
    
    func updateWeight(for date: Date, with weight: Double, source: HealthSource) async throws {
        
    }
    
    func planIsWeightDependent(on date: Date) async throws -> Bool {
        false
    }
    
    func dietaryEnergyInKcal(on date: Date) async throws -> Double? {
        nil
    }
}

public extension SettingsStore {
    /// Saves and fetches from a `.json` file encoded/decoded in the documents directory
    static func configureAsMock() {
        configure(
            fetchHandler: fetchSettingsFromDocuments,
            saveHandler: saveSettingsInDocuments
        )
    }
}

//MARK: - Private

func saveHealthInDocuments(_ health: Health, isCurrent: Bool) throws {
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
