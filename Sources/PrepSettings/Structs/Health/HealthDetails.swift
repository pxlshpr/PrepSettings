import Foundation
import HealthKit
import PrepShared


public struct HealthDetails: Hashable, Codable {
    
    public var date: Date
    
    /// Stored in `kcal`
    public var maintenance: Maintenance?
//    public var maintenanceEnergy: MaintenanceEnergy?
//    public var restingEnergy: RestingEnergy?
//    public var activeEnergy: ActiveEnergy?
    
    /// Stored in `kg`
    public var weight: Weight?
    public var leanBodyMass: LeanBodyMass?
    
    /// Stored in `cm`
    public var height: HealthQuantity?

    public var age: Age?
    public var sex: BiologicalSex?

    public var fatPercentage: Double?

    public var pregnancyStatus: PregnancyStatus?
    public var isSmoker: Bool?

    public var updatedAt: Date
    public var skipSyncAll: Bool = false
    
    public init(
        date: Date = Date.now,
        maintenance: Maintenance? = nil,
//        maintenanceEnergy: MaintenanceEnergy? = nil,
//        restingEnergy: RestingEnergy? = nil,
//        activeEnergy: ActiveEnergy? = nil,
        age: Age? = nil,
        sex: BiologicalSex? = nil,
        weight: Weight? = nil,
        height: HealthQuantity? = nil,
        leanBodyMass: LeanBodyMass? = nil,
        fatPercentage: Double? = nil,
        pregnancyStatus: PregnancyStatus? = nil,
        isSmoker: Bool? = nil,
        updatedAt: Date = Date.now
    ) {
        self.date = date
//        self.energyUnit = energyUnit
//        self.heightUnit = heightUnit
//        self.bodyMassUnit = bodyMassUnit
        self.maintenance = maintenance
//        self.maintenanceEnergy = maintenanceEnergy
//        self.restingEnergy = restingEnergy
//        self.activeEnergy = activeEnergy
        self.age = age
        self.sex = sex
        self.weight = weight
        self.height = height
        self.leanBodyMass = leanBodyMass
        self.fatPercentage = fatPercentage
        self.pregnancyStatus = pregnancyStatus
        self.isSmoker = isSmoker
        self.updatedAt = updatedAt
    }
}

public extension HealthDetails {
    /// Checks that everything except `date` and `updatedAt` match
    func matches(_ other: HealthDetails) -> Bool {
        date == other.date
//        && energyUnit == other.energyUnit
//        && heightUnit == other.heightUnit
//        && bodyMassUnit == other.bodyMassUnit
        && maintenance == other.maintenance
//        && maintenanceEnergy == other.maintenanceEnergy
//        && restingEnergy == other.restingEnergy
//        && activeEnergy == other.activeEnergy
        && age == other.age
        && sex == other.sex
        && weight == other.weight
        && height == other.height
        && leanBodyMass == other.leanBodyMass
        && fatPercentage == other.fatPercentage
        && pregnancyStatus == other.pregnancyStatus
        && isSmoker == other.isSmoker
        && skipSyncAll == other.skipSyncAll
    }
}

public extension HealthDetails {

    var leanBodyMassValue: Double? {
        leanBodyMass?.quantity?.value
    }

    var heightValue: Double? {
        height?.quantity?.value
    }
}

//public extension Health {
//    var healthSourcedCount: Int {
//        var count = 0
//        if restingEnergy?.source == .healthKit || restingEnergy == nil { count += 1 }
//        if activeEnergy?.source == .healthKit || activeEnergy == nil { count += 1 }
//        if age?.source == .healthKit || age == nil { count += 1 }
//        if sex?.source == .healthKit || sex == nil { count += 1 }
//        if weight?.source == .healthKit || weight == nil { count += 1 }
//        if height?.source == .healthKit || height == nil { count += 1 }
//        if leanBodyMass?.source == .healthKit || leanBodyMass == nil { count += 1 }
//        return count
//    }
//}
