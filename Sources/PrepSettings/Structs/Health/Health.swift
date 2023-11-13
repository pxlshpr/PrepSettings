import Foundation
import HealthKit
import PrepShared

public struct Health: Hashable, Codable {
    
    public var date: Date
    public var energyUnit: EnergyUnit
    public var heightUnit: HeightUnit
    public var bodyMassUnit: BodyMassUnit
    
    public var maintenanceEnergy: EnergyBurn?
    public var restingEnergy: RestingEnergy?
    public var activeEnergy: ActiveEnergy?
    public var age: Age?
    public var sex: BiologicalSex?
    public var weight: HealthQuantity?
    public var height: HealthQuantity?
    public var leanBodyMass: LeanBodyMass?
    
    public var fatPercentage: Double?

    public var pregnancyStatus: PregnancyStatus?
    public var isSmoker: Bool?

    public var updatedAt: Date
    
    public init(
        date: Date = Date.now,
        energyUnit: EnergyUnit = .default,
        heightUnit: HeightUnit = .default,
        bodyMassUnit: BodyMassUnit = .default,
        maintenanceEnergy: EnergyBurn? = nil,
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
        energyUnit == other.energyUnit
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
}

public extension Health {
    var usesHealthKit: Bool {
        restingEnergy?.source == .healthKit
        || activeEnergy?.source == .healthKit
        || age?.source == .healthKit
        || sex?.source == .healthKit
        || weight?.source == .healthKit
        || height?.source == .healthKit
        || leanBodyMass?.source == .healthKit
    }
}

public extension RestingEnergyEquation {
    func usesHealthKit(in health: Health) -> Bool {
        for param in self.params {
            switch param {
            case .sex:
                if health.usesHealthKitForSex { return true }
            case .age:
                if health.usesHealthKitForAge { return true }
            case .weight:
                if health.usesHealthKitForWeight { return true }
            case .leanBodyMass:
                if health.usesHealthKitForLeanBodyMass { return true }
            case .height:
                if health.usesHealthKitForHeight { return true }
            default:
                /// Remaining health types are not possible parameters
                continue
            }
        }
        return false
    }
}

public extension LeanBodyMassEquation {
    func usesHealthKit(in health: Health) -> Bool {
        for param in self.params {
            switch param {
            case .sex:
                if health.usesHealthKitForSex { return true }
            case .weight:
                if health.usesHealthKitForWeight { return true }
            case .height:
                if health.usesHealthKitForHeight { return true }
            default:
                /// Remaining health types are not possible parameters
                continue
            }
        }
        return false
    }
}

public extension Health {
    var usesHealthKitForRestingEnergy: Bool {
        switch restingEnergySource {
        case .equation:     restingEnergyEquation.usesHealthKit(in: self)
        case .healthKit:    true
        case .userEntered:  false
        }
    }
    
    var usesHealthKitForActiveEnergy: Bool {
        switch activeEnergySource {
        case .healthKit:                    true
        case .activityLevel, .userEntered:  false
        }
    }

    var usesHealthKitForMaintenanceEnergy: Bool {
        usesHealthKitForRestingEnergy || usesHealthKitForActiveEnergy
    }
    
    var usesHealthKitForWeight: Bool { weightSource == .healthKit }
    var usesHealthKitForHeight: Bool { heightSource == .healthKit }
    var usesHealthKitForSex: Bool { sexSource == .healthKit }
    var usesHealthKitForAge: Bool { ageSource == .healthKit }

    var usesHealthKitForLeanBodyMass: Bool {
        switch leanBodyMassSource {
        case .equation:         leanBodyMassEquation.usesHealthKit(in: self)
        case .fatPercentage:    usesHealthKitForWeight
        case .healthKit:        true
        case .userEntered:      false
        }
    }
}

public extension Health {
    
    struct EnergyBurn: Hashable, Codable {
        public var isCalculated: Bool
        public var calculatedValue: Double?
        
        public init(
            isCalculated: Bool = true,
            calculatedValue: Double? = nil
        ) {
            self.isCalculated = isCalculated
            self.calculatedValue = calculatedValue
        }
    }
    
    struct RestingEnergy: Hashable, Codable {
        public var source: RestingEnergySource
        public var equation: RestingEnergyEquation?
        public var interval: HealthInterval?
        public var value: Double?
        
        public init(
            source: RestingEnergySource,
            equation: RestingEnergyEquation? = nil,
            interval: HealthInterval? = nil,
            value: Double? = nil
        ) {
            self.source = source
            switch source {
            case .healthKit:
                self.equation = nil
                self.interval = interval ?? .default
            case .equation:
                self.equation = equation ?? .default
                self.interval = nil
            case .userEntered:
                self.equation = nil
                self.interval = nil
            }
            self.value = value
        }
    }
    
    struct ActiveEnergy: Hashable, Codable {
        public var source: ActiveEnergySource
        public var activityLevel: ActivityLevel?
        public var interval: HealthInterval?
        public var value: Double?
        
        public init(
            source: ActiveEnergySource,
            activityLevel: ActivityLevel? = nil,
            interval: HealthInterval? = nil,
            value: Double? = nil
        ) {
            self.source = source
            
            switch source {
            case .healthKit:
                self.activityLevel = nil
                self.interval = interval ?? .default
            case .activityLevel:
                self.activityLevel = activityLevel ?? .default
                self.interval = nil
            case .userEntered:
                self.activityLevel = nil
                self.interval = nil
            }
            
            self.value = value
        }
    }
    
    struct Age: Hashable, Codable {
        public var source: AgeSource
        public var dateOfBirthComponents: DateComponents?
        public var value: Int?
        
        public init(
            source: AgeSource,
            dateOfBirthComponents: DateComponents? = nil,
            value: Int? = nil
        ) {
            self.source = source
            self.dateOfBirthComponents = dateOfBirthComponents
            self.value = value
        }
        
        public var dateOfBirth: Date? {
            get {
                guard let dateOfBirthComponents else { return nil }
                var components = dateOfBirthComponents
                components.hour = 0
                components.minute = 0
                components.second = 0
                return Calendar.current.date(from: components)
            }
            set {
                guard let newValue else {
                    dateOfBirthComponents = nil
                    return
                }
                dateOfBirthComponents = newValue.dateComponentsWithoutTime
            }
        }
    }

    struct BiologicalSex: Hashable, Codable {
        public var source: HealthSource
        public var value: Sex?
    }

    struct LeanBodyMass: Hashable, Codable {
        public var source: LeanBodyMassSource
        public var equation: LeanBodyMassEquation?
        public var quantity: Quantity?
        
        public init(
            source: LeanBodyMassSource,
            equation: LeanBodyMassEquation? = nil,
            quantity: Quantity? = nil
        ) {
            self.source = source
            switch source {
            case .healthKit:
                self.equation = nil
            case .equation:
                self.equation = equation ?? .default
            case .fatPercentage:
                self.equation = nil
            case .userEntered:
                self.equation = nil
            }
            self.quantity = quantity
        }
    }
}

public extension Health {
    var estimatedEnergyBurn: Double? {
        guard let activeEnergyValue, let restingEnergyValue else {
            return nil
        }
        return activeEnergyValue + restingEnergyValue
    }
    
    var estimatedEnergyBurnInKcal: Double? {
        guard let estimatedEnergyBurn else { return nil }
        return energyUnit.convert(estimatedEnergyBurn, to: .kcal)
    }
    
    var estimatedEnergyBurnFormatted: String {
        guard let estimatedEnergyBurn else { return "" }
        return estimatedEnergyBurn.formattedEnergy
    }
}

public extension Health {
    
    func typeToFetchFromHealthKit(from old: Health) -> HealthType? {
        if old.weightSource != .healthKit, weightSource == .healthKit {
            return .weight
        }
        if old.leanBodyMassSource != .healthKit, leanBodyMassSource == .healthKit {
            return .leanBodyMass
        }
        if old.heightSource != .healthKit, heightSource == .healthKit {
            return .height
        }
        if old.restingEnergySource != .healthKit, restingEnergySource == .healthKit {
            return .restingEnergy
        }
        if old.activeEnergySource != .healthKit, activeEnergySource == .healthKit {
            return .activeEnergy
        }
        if old.sexSource != .healthKit, sexSource == .healthKit {
            return .sex
        }
        if old.ageSource != .healthKit, ageSource == .healthKit {
            return .age
        }
        return nil
    }

    //TODO: Remove this
    func quantityTypesToSync(from old: Health) -> [QuantityType] {
        var types: [QuantityType] = []
        if old.weightSource != .healthKit, weightSource == .healthKit {
            types.append(.weight)
        }
        if old.leanBodyMassSource != .healthKit, leanBodyMassSource == .healthKit {
            types.append(.leanBodyMass)
        }
        if old.heightSource != .healthKit, heightSource == .healthKit {
            types.append(.height)
        }
        if old.restingEnergySource != .healthKit, restingEnergySource == .healthKit {
            types.append(.restingEnergy)
        }
        if old.activeEnergySource != .healthKit, activeEnergySource == .healthKit {
            types.append(.activeEnergy)
        }
        return types
    }

    //TODO: Remove this
    func characteristicTypesToSync(from old: Health) -> [CharacteristicType] {
        var types: [CharacteristicType] = []
        if old.sexSource != .healthKit, sexSource == .healthKit {
            types.append(.sex)
        }
        if old.ageSource != .healthKit, ageSource == .healthKit {
            types.append(.dateOfBirth)
        }
        return types
    }
    
    mutating func cleanup() {
        weight?.removeDateIfNotNeeded()
    }
}

public extension Health {
    func bodyMassValue(for type: BodyMassType, in unit: BodyMassUnit? = nil) -> Double? {
        let value: Double? = switch type {
        case .weight:   weight?.quantity?.value
        case .leanMass: leanBodyMass?.quantity?.value
        }
        
        guard let value else { return nil}
        
        return if let unit {
            bodyMassUnit.convert(value, to: unit)
        } else {
            value
        }
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
