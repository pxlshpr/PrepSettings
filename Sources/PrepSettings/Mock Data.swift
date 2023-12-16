import Foundation
import PrepShared

public let MockCurrentHealthModel = HealthModel(
    delegate: MockCurrentHealthModelDelegate(),
    fetchCurrentHealthHandler: {
        let healthDetails: HealthDetails = fetchFromBackend(.currentHealthDetails)
        return healthDetails
    }
)

public var MockPastHealthModel: HealthModel {
    let healthDetails: HealthDetails = fetchFromBackend(.pastHealthDetails)
    return HealthModel(
        delegate: MockPastHealthModelDelegate(),
        health: healthDetails
    )
}

struct MockCurrentHealthModelDelegate: HealthModelDelegate {
    func saveHealth(_ healthDetails: HealthDetails, isCurrent: Bool) async throws {
        try await saveInBackend(.currentHealthDetails, healthDetails)
    }
    
    func maintenanceBackendValues(for dateRange: ClosedRange<Date>) async throws -> MaintenanceValues {
        let weights: WeightValues = fetchFromBackend(.weight)
        let dietaryEnergies: DietaryEnergyValues = fetchFromBackend(.dietaryEnergy)
        return MaintenanceValues(
            dateRange: dateRange,
            weightValues: weights,
            dietaryEnergyValues: dietaryEnergies
        )
    }
    
    func weights(for dateRange: ClosedRange<Date>) async throws -> [Date : HealthQuantity] {
        let weightValues: WeightValues = fetchFromBackend(.weight)
        return weightValues.values
    }
    
    func updateBackendWithWeight(
        _ healthQuantity: HealthQuantity?,
        for date: Date
    ) async throws {
        
        /// [ ] Load weightValues from backend, amend the value, save it
        var weightValues: WeightValues = fetchFromBackend(.weight)
        weightValues.values[date] = healthQuantity
        try await saveInBackend(.weight, weightValues)
        
//        var healthDetails: Health = fetchFromBackend(.healthDetails)
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
        let data: DietaryEnergyValues = fetchFromBackend(.dietaryEnergy)
        return data.values[date]?.dietaryEnergyInKcal
    }
}

public struct MockPastHealthModelDelegate: HealthModelDelegate {
    
    public init() { }
    
    public func saveHealth(_ healthDetails: HealthDetails, isCurrent: Bool) async throws {
        try await saveInBackend(.pastHealthDetails, healthDetails)
    }
    
    public func maintenanceBackendValues(for dateRange: ClosedRange<Date>) async throws -> MaintenanceValues {
        let weights: WeightValues = fetchFromBackend(.weight)
        let dietaryEnergies: DietaryEnergyValues = fetchFromBackend(.dietaryEnergy)
        return MaintenanceValues(
            dateRange: dateRange,
            weightValues: weights,
            dietaryEnergyValues: dietaryEnergies
        )
    }
    
    public func weights(for dateRange: ClosedRange<Date>) async throws -> [Date : HealthQuantity] {
        let weightValues: WeightValues = fetchFromBackend(.weight)
        return weightValues.values
    }
    
    public func updateBackendWithWeight(
        _ healthQuantity: HealthQuantity?,
        for date: Date
    ) async throws {
        var weightValues: WeightValues = fetchFromBackend(.weight)
        weightValues.values[date] = healthQuantity
        try await saveInBackend(.weight, weightValues)
    }
    
    public func planIsWeightDependent(on date: Date) async throws -> Bool {
        false
    }
    
    public func dietaryEnergyInKcal(on date: Date) async throws -> Double? {
        let data: DietaryEnergyValues = fetchFromBackend(.dietaryEnergy)
        return data.values[date]?.dietaryEnergyInKcal
    }
}
public extension SettingsStore {
    /// Saves and fetches from a `.json` file encoded/decoded in the documents directory
    static func configureAsMock() {
        configure(
            fetchHandler: {
                let settings: Settings = fetchFromBackend(.settings)
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

public func fetchFromBackend<T: Codable>(_ type: MockType) -> T {
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


public enum MockType: String {
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

//MARK: - HealthKit Values

func mockWeightQuantities(for date: Date) -> [Quantity]? {
//    [
//        .init(value: 93.69, date: date.startOfDay.addingTimeInterval(34560)),
//        .init(value: 94.8, date: date.startOfDay.addingTimeInterval(56520)),
//    ]
    
    [
        .init(value: 82.5, date: date.startOfDay.addingTimeInterval(14560)),
        .init(value: 83.15, date: date.startOfDay.addingTimeInterval(46520)),
    ]
//
//    [
//        .init(value: 73.69, date: date.startOfDay.addingTimeInterval(34560)),
//    ]
//
//    nil
}
