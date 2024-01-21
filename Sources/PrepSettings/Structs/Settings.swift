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
    public var dailyValueTypes: [HealthDetail : DailyValueType]

    //TODO: Remove these
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
            dailyValueTypes: [:],
            dailyValues: [:]
        )
    }
    
    var asData: Data {
        try! JSONEncoder().encode(self)
    }
}
