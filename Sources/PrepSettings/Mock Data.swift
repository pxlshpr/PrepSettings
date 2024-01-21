//import Foundation
//import PrepShared
//
////public let MockCurrentHealthModel = HealthModel(
////    delegate: MockCurrentHealthModelDelegate(),
////    fetchCurrentHealthHandler: {
////        let healthDetails: HealthDetails = fetchFromBackend(.currentHealthDetails)
////        return healthDetails
////    }
////)
//
//public var MockCurrentHealthModel: HealthModel {
//    let healthDetails: HealthDetails = fetchFromBackend(.currentHealthDetails)
//    return HealthModel(
//        delegate: MockCurrentHealthModelDelegate(),
//        health: healthDetails,
//        isCurrent: true
//    )
//}
//
//public var MockPastHealthModel: HealthModel {
//    let healthDetails: HealthDetails = fetchFromBackend(.pastHealthDetails)
//    return HealthModel(
//        delegate: MockPastHealthModelDelegate(),
//        health: healthDetails
//    )
//}
//
//struct MockCurrentHealthModelDelegate: HealthModelDelegate {
//    func saveHealth(_ healthDetails: HealthDetails, isCurrent: Bool) async throws {
//        try await saveInBackend(.currentHealthDetails, healthDetails)
//    }
//    
//    func maintenanceBackendValues(for dateRange: ClosedRange<Date>) async throws -> MaintenanceValues {
//        let weights: WeightValues = fetchFromBackend(.weight)
//        let dietaryEnergies: DietaryEnergyValues = fetchFromBackend(.dietaryEnergy)
//        return MaintenanceValues(
//            dateRange: dateRange,
//            weightValues: weights,
//            dietaryEnergyValues: dietaryEnergies
//        )
//    }
//    
//    func weights(for dateRange: ClosedRange<Date>) async throws -> [Date : HealthDetails.Weight] {
//        mockWeights(for: dateRange)
////        let weightValues: WeightValues = fetchFromBackend(.weight)
////        return weightValues.values
//    }
//    
//    func weight(for date: Date) async throws -> HealthDetails.Weight? {
//        let quantities = mockWeightQuantities(for: date)
//        return .init(
//            source: .healthKit,
//            isDailyAverage: true,
//            healthKitQuantities: quantities,
//            valueInKg: quantities?.averageValue
//        )
//    }
//    
//    func updateBackendWithWeight(
//        _ healthQuantity: HealthQuantity?,
//        for date: Date
//    ) async throws {
//        
//        /// [ ] Load weightValues from backend, amend the value, save it
//        var weightValues: WeightValues = fetchFromBackend(.weight)
//        weightValues.values[date] = healthQuantity
//        try await saveInBackend(.weight, weightValues)
//        
////        var healthDetails: Health = fetchFromBackend(.healthDetails)
////        if healthDetails.date == date {
////            if let healthQuantity {
////                healthDetails.weight = healthQuantity
////            } else {
////                healthDetails.weight = nil
////            }
////        }
////        try await saveInBackend(.healthDetails, healthDetails)
//        
//        /// **Note: ** In Prep we'll do stuff here like grab all the days that this weight might pertain to, update the HealthDetails (weight and/or adaptive maintenance), Plans, etc
//
////        var values = try await fetchMaintenanceValuesFromDocuments()
////        let value = values.values[date]
////        values.values[date] = .init(
////            weightInKg: healthQuantity?.quantity?.value,
////            dietaryEnergyInKcal: value?.dietaryEnergyInKcal,
////            dietaryEnergyType: value?.dietaryEnergyType ?? .userEntered
////        )
////        try await saveMaintenanceValuesInDocuments(values)
//    }
//    
//    func planIsWeightDependent(on date: Date) async throws -> Bool {
//        false
////        true
//    }
//    
//    func dietaryEnergyInKcal(on date: Date) async throws -> Double? {
//        
//        switch date.dateString {
//        case "2023_12_16": return 3456.25
//        case "2023_12_13": return 3300.24
//        case "2023_12_12": return 3021.4
//        case "2023_12_11": return 4024
//        default:
//            let data: DietaryEnergyValues = fetchFromBackend(.dietaryEnergy)
//            return data.values[date]?.dietaryEnergyInKcal
//        }
//    }
//}
//
//public struct MockPastHealthModelDelegate: HealthModelDelegate {
//    
//    public init() { }
//    
//    public func saveHealth(_ healthDetails: HealthDetails, isCurrent: Bool) async throws {
//        try await saveInBackend(.pastHealthDetails, healthDetails)
//    }
//    
//    public func maintenanceBackendValues(for dateRange: ClosedRange<Date>) async throws -> MaintenanceValues {
//        let weights: WeightValues = fetchFromBackend(.weight)
//        let dietaryEnergies: DietaryEnergyValues = fetchFromBackend(.dietaryEnergy)
//        return MaintenanceValues(
//            dateRange: dateRange,
//            weightValues: weights,
//            dietaryEnergyValues: dietaryEnergies
//        )
//    }
//    
//    public func weights(for dateRange: ClosedRange<Date>) async throws -> [Date : HealthDetails.Weight] {
//        mockWeights(for: dateRange)
////        let weightValues: WeightValues = fetchFromBackend(.weight)
////        return weightValues.values
//    }
//    
//    public func weight(for date: Date) async throws -> HealthDetails.Weight? {
//        let quantities = mockWeightQuantities(for: date)
//        return .init(
//            source: .healthKit,
//            isDailyAverage: true,
//            healthKitQuantities: quantities,
//            valueInKg: quantities?.averageValue
//        )
//    }
//
//    public func updateBackendWithWeight(
//        _ healthQuantity: HealthQuantity?,
//        for date: Date
//    ) async throws {
//        var weightValues: WeightValues = fetchFromBackend(.weight)
//        weightValues.values[date] = healthQuantity
//        try await saveInBackend(.weight, weightValues)
//    }
//    
//    public func planIsWeightDependent(on date: Date) async throws -> Bool {
//        false
//    }
//    
//    public func dietaryEnergyInKcal(on date: Date) async throws -> Double? {
//        let data: DietaryEnergyValues = fetchFromBackend(.dietaryEnergy)
//        return data.values[date]?.dietaryEnergyInKcal
//    }
//}
//
//public extension SettingsProvider {
//    /// Saves and fetches from a `.json` file encoded/decoded in the documents directory
//    static func configureAsMock() {
//        configure(
//            fetchHandler: {
//                let settings: Settings = fetchFromBackend(.settings)
//                return settings
//            },
//            saveHandler: { settings in
//                try await saveInBackend(.settings, settings)
//            }
//        )
//    }
//}
//
////MARK: - Helpers
//func resetMockMaintenanceValues() {
//    Task {
//        /// [ ] Save weights and dietary energy again
////        try await saveMaintenanceValuesInDocuments(.init(MockMaintenanceValues))
//    }
//}
//
//func getDocumentsDirectory() -> URL {
//    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//}
//
//public func fetchFromBackend<T: Codable>(_ type: MockType) -> T {
//    let url = getDocumentsDirectory().appendingPathComponent("\(type.rawValue).json")
//    do {
//        let data = try Data(contentsOf: url)
//        let decoded = try JSONDecoder().decode(T.self, from: data)
//        return decoded
//    } catch {
//        return type.mockValue as! T
//    }
//}
//
//func saveInBackend<T>(_ type: MockType, _ toEncode: T) async throws where T:Codable {
//    let url = getDocumentsDirectory().appendingPathComponent("\(type.rawValue).json")
//    let json = try JSONEncoder().encode(toEncode)
//    try json.write(to: url)
//}
//
//
//public enum MockType: String {
//    case currentHealthDetails
//    case pastHealthDetails
//    case settings
//    case weight
//    case dietaryEnergy
//    
//    var mockValue: Codable {
//        switch self {
//        case .currentHealthDetails: HealthDetails.init()
//        case .pastHealthDetails: HealthDetails.init(date: MockDate)
//        case .settings: Settings.default
//        case .weight: WeightValues.mock
//        case .dietaryEnergy: DietaryEnergyValues.mock
//        }
//    }
//}
//
////MARK: - Mock
//
//extension WeightValues {
//
//    static var mock: WeightValues {
//        var values: [Date : HealthQuantity] = [:]
//        for (dateString, valueInKg) in MockWeights {
//            let date = Date(fromDateString: dateString)!
//            values[date] = .init(
//                source: .userEntered,
//                isDailyAverage: false,
//                quantity: .init(value: valueInKg)
//            )
//        }
//        return .init(values: values)
//    }
//}
//
//extension DietaryEnergyValues {
//    static var mock: DietaryEnergyValues {
//        var values: [Date : Value] = [:]
//        for (dateString, valueInKg) in MockDietaryEnergy {
//            let date = Date(fromDateString: dateString)!
//            values[date] = .init(
//                dietaryEnergyInKcal: valueInKg,
//                dietaryEnergyType: .logged
//            )
//        }
//        return .init(values: values)
//    }
//}
//
//let MockWeights: [String : Double] = [
//    "2021_08_27": 93,
//    "2021_08_23": 94,
//    "2021_08_21": 94.5,
//    "2021_08_19": 92.4,
//    "2021_08_18": 94.15,
//    "2021_08_16": 92.75,
//    "2021_08_07": 96.35,
//]
//
//let MockDietaryEnergy: [String: Double] = [
//    "2021_08_27": 1800,
//    "2021_08_22": 2300,
//    "2021_08_20": 2250,
//    "2021_08_19": 1950,
//    "2021_08_18": 2650,
//    "2021_08_17": 2534,
//    "2021_08_16": 2304,
//    "2021_08_15": 2055,
//    "2021_08_07": 1965,
//]
//
////MARK: - HealthKit Values
//
//extension Date {
//    func at(h: Int, m: Int) -> Date {
//        let timeString = String(format: "%02d_%02d", h, m)
//        return Date(fromTimeString: "\(dateString)-\(timeString)")!
//    }
//}
//
//extension ClosedRange<Date> {
//    var startOfDays: [Date] {
//        let dayDurationInSeconds: TimeInterval = 60*60*24
//        var dates: [Date] = []
//        for date in stride(
//            from: lowerBound.startOfDay,
//            to: upperBound.startOfDay,
//            by: dayDurationInSeconds
//        ) {
//            dates.append(date)
//        }
//        return dates
//    }
//}
//
//func mockWeights(for dateRange: ClosedRange<Date>) -> [Date : HealthDetails.Weight] {
//    var weights: [Date : HealthDetails.Weight] = [:]
//
//    for date in dateRange.startOfDays {
//        let quantities = mockWeightQuantities(for: date)
//        weights[date] = .init(
//            source: .healthKit,
//            isDailyAverage: true,
//            healthKitQuantities: quantities,
//            valueInKg: quantities?.averageValue
//        )
//    }
//    return weights
//}
//
//func mockWeightQuantities(for date: Date) -> [Quantity]? {
//    switch date.dateString {
//    case Date.now.dateString:
//            [
//                .init(value: 93.69, date: date.at(h: 9, m: 32)),
//                .init(value: 94.8, date: date.at(h: 12, m: 36)),
//            ]
//    case Date.now.moveDayBy(-1).dateString:
//        [
//            .init(value: 92.5, date: date.at(h: 9, m: 32)),
//            .init(value: 93.1, date: date.at(h: 12, m: 36)),
//        ]
//        
//    case Date.now.moveDayBy(-7).dateString:
//        [
//            .init(value: 96.5, date: date.startOfDay.addingTimeInterval(34560)),
//            .init(value: 97.2, date: date.startOfDay.addingTimeInterval(56520)),
//        ]
//    case "2023_12_16":
//        nil
//    default:
//        //    [
//        //        .init(value: 93.69, date: date.startOfDay.addingTimeInterval(34560)),
//        //        .init(value: 94.8, date: date.startOfDay.addingTimeInterval(56520)),
//        //    ]
//            
//            [
//                .init(value: 82.5, date: date.startOfDay.addingTimeInterval(14560)),
//                .init(value: 83.15, date: date.startOfDay.addingTimeInterval(46520)),
//            ]
//        //
//        //    [
//        //        .init(value: 73.69, date: date.startOfDay.addingTimeInterval(34560)),
//        //    ]
//        //
//        //    nil
//    }
//}
