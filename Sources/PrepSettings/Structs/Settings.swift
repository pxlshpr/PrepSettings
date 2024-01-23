import Foundation
import PrepShared

public struct Settings: Codable, Hashable {
    
    public var energyUnit: EnergyUnit
    public var bodyMassUnit: BodyMassUnit
    public var heightUnit: HeightUnit
    public var volumeUnits: VolumeUnits
    
    public var macrosBarType: MacrosBarType
    
    public var nutrientsFilter: NutrientsFilter
    public var showRDAGoals: Bool
    public var expandedMicroGroups: [MicroGroup]
    public var metricType: GoalMetricType
    
    public var displayedMicros: [Micro]
    
    public var healthKitSyncedHealthDetails: [HealthDetail]
    public var dailyMeasurementTypes: [HealthDetail : DailyMeasurementType] = [:]
    
    public var compactNutrients: [Nutrient]

    //TODO: Remove this
    /// [ ] Because these should be per-day, similar to `Plan` and `HealthDetails`
    public var dailyValues: [Micro: DailyValue]
}

public extension Settings {
    static var `default`: Settings {
        Settings(
            energyUnit: .kcal,
            bodyMassUnit: .kg,
            heightUnit: .cm,
            volumeUnits: .defaultUnits,
            macrosBarType: .foodItem,
            nutrientsFilter: .all,
            showRDAGoals: true,
            expandedMicroGroups: [],
            metricType: .consumed,
            displayedMicros: [],
            healthKitSyncedHealthDetails: [],
            dailyMeasurementTypes: [:],
            compactNutrients: [.energy, .macro(.protein), .macro(.carb), .macro(.fat)],
            dailyValues: [:]
        )
    }
    
    var asData: Data {
        try! JSONEncoder().encode(self)
    }
}

extension Settings {

    mutating func setDailyMeasurementType(_ type: DailyMeasurementType, for healthDetail: HealthDetail) {
        dailyMeasurementTypes[healthDetail] = type
    }

    func dailyMeasurementType(for healthDetail: HealthDetail) -> DailyMeasurementType {
        dailyMeasurementTypes[healthDetail] ?? .last
    }

    func dailyMeasurementType(forHealthKitType type: HealthKitType) -> DailyMeasurementType? {
        guard let healthDetail = type.healthDetail else { return nil }
        return dailyMeasurementType(for: healthDetail)
    }

    func isHealthKitSyncing(_ healthDetail: HealthDetail) -> Bool {
        healthKitSyncedHealthDetails.contains(healthDetail)
    }
    
    mutating func setHealthKitSyncing(for healthDetail: HealthDetail, to isOn: Bool) {
        switch isOn {
        case true:
            guard !isHealthKitSyncing(healthDetail) else { return }
            healthKitSyncedHealthDetails.append(healthDetail)
        case false:
            healthKitSyncedHealthDetails.removeAll(where: { $0 == healthDetail })
        }
    }
}
