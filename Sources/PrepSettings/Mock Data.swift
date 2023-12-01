import Foundation
import PrepShared

public let MockHealthModel = HealthModel(
    delegate: MockHealthModelDelegate(),
    fetchCurrentHealthHandler: fetchHealthFromDocuments
//    saveHandler: saveHealthInDocuments
)

struct MockHealthModelDelegate: HealthModelDelegate {
    func saveHealth(_ health: Health, isCurrent: Bool) async throws {
        try saveHealthInDocuments(health, isCurrent: isCurrent)
    }
    
    func maintenanceBackendValues(for dateRange: ClosedRange<Date>) async throws -> MaintenanceValues {
        .init(MockMaintenanceValues)
//        try await fetchMaintenanceValuesFromDocuments()
    }
    
    func updateBackendWeight(for date: Date, with quantity: Quantity?, source: HealthSource) async throws {
        /// [ ] Load the struct from documents—simply amend the value we have, and then save it so that we can test the persistencen
        var values = try await fetchMaintenanceValuesFromDocuments()
        let value = values.values[date]
        values.values[date] = .init(
            weightInKg: quantity?.value,
            dietaryEnergyInKcal: value?.dietaryEnergyInKcal,
            dietaryEnergyType: value?.dietaryEnergyType ?? .userEntered
        )
        try await saveMaintenanceValuesInDocuments(values)
    }
    
    func planIsWeightDependent(on date: Date) async throws -> Bool {
        false
//        true
    }
    
    func dietaryEnergyInKcal(on date: Date) async throws -> Double? {
        try await fetchMaintenanceValuesFromDocuments()
            .dietaryEnergyInKcal(for: date)
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

public struct MaintenanceValues: Codable {
    
    public var values: [Date: Value]
    
    public struct Value: Codable {
        public var weightInKg: Double?
        public var dietaryEnergyInKcal: Double?
        public var dietaryEnergyType: DietaryEnergySampleType
        
        public init(
            weightInKg: Double? = nil,
            dietaryEnergyInKcal: Double? = nil,
            dietaryEnergyType: DietaryEnergySampleType
        ) {
            self.weightInKg = weightInKg
            self.dietaryEnergyInKcal = dietaryEnergyInKcal
            self.dietaryEnergyType = dietaryEnergyType
        }
    }
    
    public init(values: [Date : Value]) {
        self.values = values
    }
    
    public init(_ dict: [Date: (Double?, Double?)]) {
        var values: [Date: Value] = [:]
        for (date, (weight, energy)) in dict {
            let value = Value(
                weightInKg: weight,
                dietaryEnergyInKcal: energy,
                dietaryEnergyType: .logged
            )
            values[date] = value
        }
        self.values = values
    }
}

public extension MaintenanceValues {
    mutating func setWeightInKg(_ value: Double, for date: Date) {
        values[date]?.weightInKg = value
    }
    
    mutating func setDietaryEnergyInKcal(_ value: Double, for date: Date, type: DietaryEnergySampleType) {
        values[date]?.dietaryEnergyInKcal = value
        values[date]?.dietaryEnergyType = type
    }
    
    func weightInKg(on date: Date) -> Double? {
        values[date]?.weightInKg
    }
    
    func dietaryEnergyInKcal(for date: Date) -> Double? {
        values[date]?.dietaryEnergyInKcal
    }
    
    func dietaryEnergyType(for date: Date) -> DietaryEnergySampleType? {
        values[date]?.dietaryEnergyType
    }
}

let MockMaintenanceValues = [
    Date(fromDateString: "2021_08_28")!: (nil, 1800.0),
    Date(fromDateString: "2021_08_27")!: (93, nil), /// weight
    Date(fromDateString: "2021_08_26")!: (nil, nil), /// weight
    Date(fromDateString: "2021_08_25")!: (nil, nil),
    Date(fromDateString: "2021_08_24")!: (nil, nil),
    Date(fromDateString: "2021_08_23")!: (94, nil), /// weight
    Date(fromDateString: "2021_08_22")!: (nil, 2300),
    Date(fromDateString: "2021_08_21")!: (94.5, nil),

    Date(fromDateString: "2021_08_20")!: (nil, 2250),
    Date(fromDateString: "2021_08_19")!: (92.4, 1950), /// weight
    Date(fromDateString: "2021_08_18")!: (94.15, 2650), /// weight
    Date(fromDateString: "2021_08_17")!: (nil, 2534),
    Date(fromDateString: "2021_08_16")!: (92.75, 2304), /// weight
    Date(fromDateString: "2021_08_15")!: (nil, 2055),
    Date(fromDateString: "2021_08_14")!: (nil, nil),
]

func resetMockMaintenanceValues() {
    Task {
        try await saveMaintenanceValuesInDocuments(.init(MockMaintenanceValues))
    }
}

func fetchMaintenanceValuesFromDocuments() async throws -> MaintenanceValues {
    let url = getDocumentsDirectory().appendingPathComponent("maintenanceValues.json")
    do {
        let data = try Data(contentsOf: url)
        let settings = try JSONDecoder().decode(MaintenanceValues.self, from: data)
        return settings
    } catch {
//        return .init([
//            Date(fromDateString: "2021_08_28")!: (nil, 1800),
//            Date(fromDateString: "2021_08_27")!: (nil, nil), /// weight
//            Date(fromDateString: "2021_08_26")!: (nil, nil), /// weight
//            Date(fromDateString: "2021_08_25")!: (nil, nil),
//            Date(fromDateString: "2021_08_24")!: (nil, nil),
//            Date(fromDateString: "2021_08_23")!: (nil, nil), /// weight
//            Date(fromDateString: "2021_08_22")!: (95, 2300),
//            Date(fromDateString: "2021_08_21")!: (97, nil),
//
//            Date(fromDateString: "2021_08_20")!: (96, 2250),
//            Date(fromDateString: "2021_08_19")!: (99, 1950), /// weight
//            Date(fromDateString: "2021_08_18")!: (102.5, 2650), /// weight
//            Date(fromDateString: "2021_08_17")!: (100.2, 2534),
//            Date(fromDateString: "2021_08_16")!: (98, 2304), /// weight
//            Date(fromDateString: "2021_08_15")!: (103.1, 2055),
//            Date(fromDateString: "2021_08_14")!: (101.5, nil),
//        ])

        return .init(MockMaintenanceValues)

        /** Backend values
         
         ([(String, Double)]) 15 values {
           [0] = (0 = "2021_08_28", 1 = 1484.5368347167969)
           [1] = (0 = "2021_08_27", 1 = 2305.0751342773438)
           [2] = (0 = "2021_08_26", 1 = 3163.2059326171875)
           [3] = (0 = "2021_08_25", 1 = 2700.6404113769531)
           [4] = (0 = "2021_08_24", 1 = 2472.1461486816406)
           [5] = (0 = "2021_08_23", 1 = 1757.1208801269531)
           [6] = (0 = "2021_08_22", 1 = 1120.2774810791016)
           [7] = (0 = "2021_08_21", 1 = 3101.9911499023438)
           [8] = (0 = "2021_08_20", 1 = 1178.87060546875)
           [9] = (0 = "2021_08_19", 1 = 342)
           [10] = (0 = "2021_08_18", 1 = 920.5604248046875)
           [11] = (0 = "2021_08_17", 1 = 660)
           [12] = (0 = "2021_08_16", 1 = 1039.3082275390625)
           [13] = (0 = "2021_08_15", 1 = 1182.8685913085938)
           [14] = (0 = "2021_08_14", 1 = 2335.6041564941406)
         }
         
         ([(String, Double?, Int)]) 6 values {
           [0] = (0 = "2021_08_27", 1 = 93.549631977405041, 2 = 3)
           [1] = (0 = "2021_08_26", 1 = 91.050026410931323, 2 = 4)
           [2] = (0 = "2021_08_23", 1 = 94.500039975207358, 2 = 4)
           [3] = (0 = "2021_08_19", 1 = 92.400000000000005, 2 = 1)
           [4] = (0 = "2021_08_18", 1 = 94.14995107469636, 2 = 4)
           [5] = (0 = "2021_08_16", 1 = 92.750059905886246, 2 = 4)
         }
         */
    }
}

func saveMaintenanceValuesInDocuments(_ values: MaintenanceValues) async throws {
    let url = getDocumentsDirectory().appendingPathComponent("maintenanceValues.json")
    let json = try JSONEncoder().encode(values)
    try json.write(to: url)
}

func saveSettingsInDocuments(_ settings: Settings) async throws {
    let url = getDocumentsDirectory().appendingPathComponent("settings.json")
    let json = try JSONEncoder().encode(settings)
    try json.write(to: url)
}
    
func getDocumentsDirectory() -> URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
}
