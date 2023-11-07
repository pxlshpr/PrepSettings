import Foundation
import HealthKit
import PrepShared

public struct Biometrics: Hashable, Codable {
    
    public var date: Date
    public var energyUnit: EnergyUnit
    public var heightUnit: HeightUnit
    public var bodyMassUnit: BodyMassUnit
    
    public var restingEnergy: RestingEnergy?
    public var activeEnergy: ActiveEnergy?
    public var age: Age?
    public var sex: Sex?
    public var weight: BiometricQuantity?
    public var height: BiometricQuantity?
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
        restingEnergy: RestingEnergy? = nil,
        activeEnergy: ActiveEnergy? = nil,
        age: Age? = nil,
        sex: Sex? = nil,
        weight: BiometricQuantity? = nil,
        height: BiometricQuantity? = nil,
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

public extension Biometrics {
    /// Checks that everything except `date` and `updatedAt` match
    func matches(_ other: Biometrics) -> Bool {
        energyUnit == other.energyUnit
        && heightUnit == other.heightUnit
        && bodyMassUnit == other.bodyMassUnit
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

public extension Biometrics {
    var usesHealth: Bool {
        restingEnergy?.source == .health
        || activeEnergy?.source == .health
        || age?.source == .health
        || sex?.source == .health
        || weight?.source == .health
        || height?.source == .health
        || leanBodyMass?.source == .health
    }
}

public extension RestingEnergyEquation {
    func usesHealth(in biometrics: Biometrics) -> Bool {
        for param in self.params {
            switch param {
            case .sex:
                if biometrics.usesHealthForSex { return true }
            case .age:
                if biometrics.usesHealthForAge { return true }
            case .weight:
                if biometrics.usesHealthForWeight { return true }
            case .leanBodyMass:
                if biometrics.usesHealthForLeanBodyMass { return true }
            case .height:
                if biometrics.usesHealthForHeight { return true }
            default:
                /// Remaining biometric types are not possible parameters
                continue
            }
        }
        return false
    }
}

public extension LeanBodyMassEquation {
    func usesHealth(in biometrics: Biometrics) -> Bool {
        for param in self.params {
            switch param {
            case .sex:
                if biometrics.usesHealthForSex { return true }
            case .weight:
                if biometrics.usesHealthForWeight { return true }
            case .height:
                if biometrics.usesHealthForHeight { return true }
            default:
                /// Remaining biometric types are not possible parameters
                continue
            }
        }
        return false
    }
}

public extension Biometrics {
    var usesHealthForRestingEnergy: Bool {
        switch restingEnergySource {
        case .equation:     restingEnergyEquation.usesHealth(in: self)
        case .health:       true
        case .userEntered:  false
        }
    }
    
    var usesHealthForActiveEnergy: Bool {
        switch activeEnergySource {
        case .health:                       true
        case .activityLevel, .userEntered:  false
        }
    }

    var usesHealthForMaintenanceEnergy: Bool {
        usesHealthForRestingEnergy || usesHealthForActiveEnergy
    }
    
    var usesHealthForWeight: Bool { weightSource == .health }
    var usesHealthForHeight: Bool { heightSource == .health }
    var usesHealthForSex: Bool { sexSource == .health }
    var usesHealthForAge: Bool { ageSource == .health }

    var usesHealthForLeanBodyMass: Bool {
        switch leanBodyMassSource {
        case .equation:         leanBodyMassEquation.usesHealth(in: self)
        case .fatPercentage:    usesHealthForWeight
        case .health:           true
        case .userEntered:      false
        }
    }
}

public extension Biometrics {
    
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
            case .health:
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
            case .health:
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
                dateOfBirthComponents = Calendar.current.dateComponents(
                    [.year, .month, .day],
                    from: newValue
                )
            }
        }
    }

    struct Sex: Hashable, Codable {
        public var source: BiometricSource
        public var value: BiometricSex?
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
            case .health:
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

public extension Biometrics {
    var maintenanceEnergy: Double? {
        guard let activeEnergyValue, let restingEnergyValue else {
            return nil
        }
        return activeEnergyValue + restingEnergyValue
    }
    
    var maintenanceEnergyInKcal: Double? {
        guard let maintenanceEnergy else { return nil }
        return energyUnit.convert(maintenanceEnergy, to: .kcal)
    }
    
    var maintenanceEnergyFormatted: String {
        guard let maintenanceEnergy else { return "" }
        return maintenanceEnergy.formattedEnergy
    }
}

public extension Biometrics {
    
    func quantityTypesToSync(from old: Biometrics) -> [QuantityType] {
        var types: [QuantityType] = []
        if old.weightSource != .health, weightSource == .health {
            types.append(.weight)
        }
        if old.leanBodyMassSource != .health, leanBodyMassSource == .health {
            types.append(.leanBodyMass)
        }
        if old.heightSource != .health, heightSource == .health {
            types.append(.height)
        }
        if old.restingEnergySource != .health, restingEnergySource == .health {
            types.append(.restingEnergy)
        }
        if old.activeEnergySource != .health, activeEnergySource == .health {
            types.append(.activeEnergy)
        }
        return types
    }

    func characteristicTypesToSync(from old: Biometrics) -> [CharacteristicType] {
        var types: [CharacteristicType] = []
        if old.sexSource != .health, sexSource == .health {
            types.append(.sex)
        }
        if old.ageSource != .health, ageSource == .health {
            types.append(.dateOfBirth)
        }
        return types
    }
    
    mutating func cleanup() {
        weight?.removeDateIfNotNeeded()
    }
}

public extension Biometrics {
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

public extension Biometrics {
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

public extension Biometrics {
    var healthSourcedCount: Int {
        var count = 0
        if restingEnergy?.source == .health || restingEnergy == nil { count += 1 }
        if activeEnergy?.source == .health || activeEnergy == nil { count += 1 }
        if age?.source == .health || age == nil { count += 1 }
        if sex?.source == .health || sex == nil { count += 1 }
        if weight?.source == .health || weight == nil { count += 1 }
        if height?.source == .health || height == nil { count += 1 }
        if leanBodyMass?.source == .health || leanBodyMass == nil { count += 1 }
        return count
    }
}
