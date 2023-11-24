import Foundation
import HealthKit
import PrepShared

public struct Health: Hashable, Codable {
    
    public var date: Date
    
    public var energyUnit: EnergyUnit
    public var heightUnit: HeightUnit
    public var bodyMassUnit: BodyMassUnit
    
    /// Stored in `kcal`
    public var maintenanceEnergy: MaintenanceEnergy?
    public var restingEnergy: RestingEnergy?
    public var activeEnergy: ActiveEnergy?
    
    /// Stored in `kg`
    public var weight: HealthQuantity?
    public var leanBodyMass: LeanBodyMass?
    
    /// Stored in `cm`
    public var height: HealthQuantity?

    public var age: Age?
    public var sex: BiologicalSex?

    public var fatPercentage: Double?

    public var pregnancyStatus: PregnancyStatus?
    public var isSmoker: Bool?

    public var updatedAt: Date
    
    public init(
        date: Date = Date.now,
        energyUnit: EnergyUnit = .default,
        heightUnit: HeightUnit = .default,
        bodyMassUnit: BodyMassUnit = .default,
        maintenanceEnergy: MaintenanceEnergy? = nil,
        restingEnergy: RestingEnergy? = nil,
        activeEnergy: ActiveEnergy? = nil,
        age: Age? = nil,
        sex: BiologicalSex? = nil,
        weight: HealthQuantity? = nil,
        height: HealthQuantity? = nil,
        leanBodyMass: LeanBodyMass? = nil,
        fatPercentage: Double? = nil,
        pregnancyStatus: PregnancyStatus? = nil,
        isSmoker: Bool? = nil,
        updatedAt: Date = Date.now
    ) {
        self.date = date
        self.energyUnit = energyUnit
        self.heightUnit = heightUnit
        self.bodyMassUnit = bodyMassUnit
        self.maintenanceEnergy = maintenanceEnergy
        self.restingEnergy = restingEnergy
        self.activeEnergy = activeEnergy
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

public extension Health {
    /// Checks that everything except `date` and `updatedAt` match
    func matches(_ other: Health) -> Bool {
        date == other.date
        && energyUnit == other.energyUnit
        && heightUnit == other.heightUnit
        && bodyMassUnit == other.bodyMassUnit
        && maintenanceEnergy == other.maintenanceEnergy
        && restingEnergy == other.restingEnergy
        && activeEnergy == other.activeEnergy
        && age == other.age
        && sex == other.sex
        && weight == other.weight
        && height == other.height
        && leanBodyMass == other.leanBodyMass
        && fatPercentage == other.fatPercentage
        && pregnancyStatus == other.pregnancyStatus
        && isSmoker == other.isSmoker
    }

    mutating func cleanup() {
        weight?.removeDateIfNotNeeded()
    }
}

public extension Health {
    var weightInKg: Double? {
        guard let value = weight?.quantity?.value else { return nil }
        return bodyMassUnit.convert(value, to: .kg)
    }

    var lbmInKg: Double? {
        guard let value = leanBodyMass?.quantity?.value else { return nil }
        return bodyMassUnit.convert(value, to: .kg)
    }

    var heightInCm: Double? {
        guard let value = height?.quantity?.value else { return nil }
        return heightUnit.convert(value, to: .cm)
    }
}

public extension Health {
    var healthSourcedCount: Int {
        var count = 0
        if restingEnergy?.source == .healthKit || restingEnergy == nil { count += 1 }
        if activeEnergy?.source == .healthKit || activeEnergy == nil { count += 1 }
        if age?.source == .healthKit || age == nil { count += 1 }
        if sex?.source == .healthKit || sex == nil { count += 1 }
        if weight?.source == .healthKit || weight == nil { count += 1 }
        if height?.source == .healthKit || height == nil { count += 1 }
        if leanBodyMass?.source == .healthKit || leanBodyMass == nil { count += 1 }
        return count
    }
}
