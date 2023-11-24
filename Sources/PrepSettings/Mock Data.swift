import Foundation

public let MockHealthModel = HealthModel(
    delegate: MockHealthModelDelegate(),
    fetchCurrentHealthHandler: fetchHealthFromDocuments
//    saveHandler: saveHealthInDocuments
)

struct MockHealthModelDelegate: HealthModelDelegate {
    func saveHealth(_ health: Health, isCurrent: Bool) async throws {
        try saveHealthInDocuments(health, isCurrent: isCurrent)
    }
    
    func maintenanceData(for dateRange: ClosedRange<Date>) async throws -> [Date : (weightInKg: Double?, dietaryEnergyInKcal: Double?)] {
        [:]
    }
    
    func updateWeight(for date: Date, with weight: Double?, source: HealthSource) async throws {
        
    }
    
    func planIsWeightDependent(on date: Date) async throws -> Bool {
        true
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

func fetchHealthFromDocuments() async throws -> Health {
    let url = getDocumentsDirectory().appendingPathComponent("health.json")
    do {
        let data = try Data(contentsOf: url)
        var health = try JSONDecoder().decode(Health.self, from: data)
//        health.date = Date.now.moveDayBy(-15)
//        health.date = Date(fromDateString: "2023_02_26")!
        health.date = Date(fromDateString: "2021_08_28")!
        return health
    } catch {
        return .init()
    }
}

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
