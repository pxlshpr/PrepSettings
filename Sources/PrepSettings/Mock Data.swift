import Foundation
import PrepShared

public let MockCurrentHealthModel = HealthModel(
    delegate: MockCurrentHealthModelDelegate(),
    fetchCurrentHealthHandler: {
        let healthDetails: HealthDetails = try await fetchFromBackend(.currentHealthDetails)
        return healthDetails
    }
)

public let MockPastHealthModel = HealthModel(
    delegate: MockPastHealthModelDelegate(),
    fetchCurrentHealthHandler: {
        let healthDetails: HealthDetails = try await fetchFromBackend(.pastHealthDetails)
        return healthDetails
    }
)

struct MockCurrentHealthModelDelegate: HealthModelDelegate {
    func saveHealth(_ healthDetails: HealthDetails, isCurrent: Bool) async throws {
        try await saveInBackend(.currentHealthDetails, healthDetails)
    }
    
    func maintenanceBackendValues(for dateRange: ClosedRange<Date>) async throws -> MaintenanceValues {
        let weights: WeightValues = try await fetchFromBackend(.weight)
        let dietaryEnergies: DietaryEnergyValues = try await fetchFromBackend(.dietaryEnergy)
        return MaintenanceValues(
            dateRange: dateRange,
            weightValues: weights,
            dietaryEnergyValues: dietaryEnergies
        )
    }
    
    func weights(for dateRange: ClosedRange<Date>) async throws -> [Date : HealthQuantity] {
        let weightValues: WeightValues = try await fetchFromBackend(.weight)
        return weightValues.values
    }
    
    func updateBackendWithWeight(
        _ healthQuantity: HealthQuantity?,
        for date: Date
    ) async throws {
        
        /// [ ] Load weightValues from backend, amend the value, save it
        var weightValues: WeightValues = try await fetchFromBackend(.weight)
        weightValues.values[date] = healthQuantity
        try await saveInBackend(.weight, weightValues)
        
//        var healthDetails: Health = try await fetchFromBackend(.healthDetails)
//        if healthDetails.date == date {
//            if let healthQuantity {
//                healthDetails.weight = healthQuantity
//            } else {
//                healthDetails.weight = nil
//            }
//        }
//        try await saveInBackend(.healthDetails, healthDetails)
        
        /// **Note: ** In Prep we'll do stuff here like grab all the days that this weight might pertain to, update the HealthDetails (weight and/or adaptive maintenance), Plans, etc

//        var values = try await fetchMaintenanceValuesFromDocuments()
//        let value = values.values[date]
//        values.values[date] = .init(
//            weightInKg: healthQuantity?.quantity?.value,
//            dietaryEnergyInKcal: value?.dietaryEnergyInKcal,
//            dietaryEnergyType: value?.dietaryEnergyType ?? .userEntered
//        )
//        try await saveMaintenanceValuesInDocuments(values)
    }
    
    func planIsWeightDependent(on date: Date) async throws -> Bool {
        false
//        true
    }
    
    func dietaryEnergyInKcal(on date: Date) async throws -> Double? {
        let data: DietaryEnergyValues = try await fetchFromBackend(.dietaryEnergy)
        return data.values[date]?.dietaryEnergyInKcal
    }
}

struct MockPastHealthModelDelegate: HealthModelDelegate {
    func saveHealth(_ healthDetails: HealthDetails, isCurrent: Bool) async throws {
        try await saveInBackend(.pastHealthDetails, healthDetails)
    }
    
    func maintenanceBackendValues(for dateRange: ClosedRange<Date>) async throws -> MaintenanceValues {
        let weights: WeightValues = try await fetchFromBackend(.weight)
        let dietaryEnergies: DietaryEnergyValues = try await fetchFromBackend(.dietaryEnergy)
        return MaintenanceValues(
            dateRange: dateRange,
            weightValues: weights,
            dietaryEnergyValues: dietaryEnergies
        )
    }
    
    func weights(for dateRange: ClosedRange<Date>) async throws -> [Date : HealthQuantity] {
        let weightValues: WeightValues = try await fetchFromBackend(.weight)
        return weightValues.values
    }
    
    func updateBackendWithWeight(
        _ healthQuantity: HealthQuantity?,
        for date: Date
    ) async throws {
        var weightValues: WeightValues = try await fetchFromBackend(.weight)
        weightValues.values[date] = healthQuantity
        try await saveInBackend(.weight, weightValues)
    }
    
    func planIsWeightDependent(on date: Date) async throws -> Bool {
        false
    }
    
    func dietaryEnergyInKcal(on date: Date) async throws -> Double? {
        let data: DietaryEnergyValues = try await fetchFromBackend(.dietaryEnergy)
        return data.values[date]?.dietaryEnergyInKcal
    }
}
public extension SettingsStore {
    /// Saves and fetches from a `.json` file encoded/decoded in the documents directory
    static func configureAsMock() {
        configure(
            fetchHandler: {
                let settings: Settings = try await fetchFromBackend(.settings)
                return settings
            },
            saveHandler: { settings in
                try await saveInBackend(.settings, settings)
            }
        )
    }
}

//MARK: - Helpers
func resetMockMaintenanceValues() {
    Task {
        /// [ ] Save weights and dietary energy again
//        try await saveMaintenanceValuesInDocuments(.init(MockMaintenanceValues))
    }
}

func getDocumentsDirectory() -> URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
}

func fetchFromBackend<T: Codable>(_ type: MockType) async throws -> T {
    let url = getDocumentsDirectory().appendingPathComponent("\(type.rawValue).json")
    do {
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode(T.self, from: data)
        return decoded
    } catch {
        return type.mockValue as! T
    }
}

func saveInBackend<T>(_ type: MockType, _ toEncode: T) async throws where T:Codable {
    let url = getDocumentsDirectory().appendingPathComponent("\(type.rawValue).json")
    let json = try JSONEncoder().encode(toEncode)
    try json.write(to: url)
}


enum MockType: String {
    case currentHealthDetails
    case pastHealthDetails
    case settings
    case weight
    case dietaryEnergy
    
    var mockValue: Codable {
        switch self {
        case .currentHealthDetails: HealthDetails.init()
        case .pastHealthDetails: HealthDetails.init(date: MockDate)
        case .settings: Settings.default
        case .weight: WeightValues.mock
        case .dietaryEnergy: DietaryEnergyValues.mock
        }
    }
}

//MARK: - Mock

extension WeightValues {

    static var mock: WeightValues {
        var values: [Date : HealthQuantity] = [:]
        for (dateString, valueInKg) in MockWeights {
            let date = Date(fromDateString: dateString)!
            values[date] = .init(
                source: .userEntered,
                isDailyAverage: false,
                quantity: .init(value: valueInKg)
            )
        }
        return .init(values: values)
    }
}

extension DietaryEnergyValues {
    static var mock: DietaryEnergyValues {
        var values: [Date : Value] = [:]
        for (dateString, valueInKg) in MockDietaryEnergy {
            let date = Date(fromDateString: dateString)!
            values[date] = .init(
                dietaryEnergyInKcal: valueInKg,
                dietaryEnergyType: .logged
            )
        }
        return .init(values: values)
    }
}

let MockWeights: [String : Double] = [
    "2021_08_27": 93,
    "2021_08_23": 94,
    "2021_08_21": 94.5,
    "2021_08_19": 92.4,
    "2021_08_18": 94.15,
    "2021_08_16": 92.75,
    "2021_08_07": 96.35,
]

let MockDietaryEnergy: [String: Double] = [
    "2021_08_27": 1800,
    "2021_08_22": 2300,
    "2021_08_20": 2250,
    "2021_08_19": 1950,
    "2021_08_18": 2650,
    "2021_08_17": 2534,
    "2021_08_16": 2304,
    "2021_08_15": 2055,
    "2021_08_07": 1965,
]
