import Foundation
import PrepShared
import HealthKit

public enum HealthKitValue {
    case weight([Quantity]?)
    case height(Quantity?)
    case leanBodyMass(Quantity?)
    
    case restingEnergy(Double?)
    case activeEnergy(Double?)
    
    case adaptiveMaintenance(HealthDetails.Maintenance.Adaptive)

    case sex(HKBiologicalSex?)
    case age(DateComponents?)
}

extension HealthKitValue {
    static func zeroValue(for type: HealthType) -> HealthKitValue? {
        switch type {
        case .restingEnergy:    .restingEnergy(0)
        case .activeEnergy:     .activeEnergy(0)
        default:
            nil
        }
    }
}

public extension HealthKitValue {
    var quantities: [Quantity]? {
        switch self {
        case .weight(let quantities):       quantities
        default: nil
        }
    }
    var quantity: Quantity? {
        switch self {
        case .height(let quantity):         quantity
        case .leanBodyMass(let quantity):   quantity
        default: nil
        }
    }
    
    var sex: Sex? {
        switch self {
        case .sex(let biologicalSex): biologicalSex?.sex
        default: nil
        }
    }
    
    var dateComponents: DateComponents? {
        switch self {
        case .age(let dateComponents): dateComponents
        default: nil
        }
    }

    var double: Double? {
        switch self {
        case .adaptiveMaintenance(let adaptiveMaintenance): adaptiveMaintenance.value
        case .activeEnergy(let double):                     double
        case .restingEnergy(let double):                    double
        default: nil
        }
    }

    var adaptiveMaintenance: HealthDetails.Maintenance.Adaptive? {
        switch self {
        case .adaptiveMaintenance(let adaptiveMaintenance): adaptiveMaintenance
        default: nil
        }
    }
}
