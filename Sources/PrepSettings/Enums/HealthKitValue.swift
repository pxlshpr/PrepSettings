import Foundation
import PrepShared
import HealthKit

public enum HealthKitValue {
    case weight(Quantity?)
    case height(Quantity?)
    case leanBodyMass(Quantity?)
    
    case restingEnergy(Double?)
    case activeEnergy(Double?)
    
    case maintenanceEnergy(Health.MaintenanceEnergy)

    case sex(HKBiologicalSex?)
    case age(DateComponents?)
}

public extension HealthKitValue {
    var quantity: Quantity? {
        switch self {
        case .weight(let quantity):         quantity
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
        case .maintenanceEnergy(let maintenanceEnergy):  maintenanceEnergy.adaptiveValue
        case .activeEnergy(let double):                     double
        case .restingEnergy(let double):                    double
        default: nil
        }
    }

    var maintenanceEnergy: Health.MaintenanceEnergy? {
        switch self {
        case .maintenanceEnergy(let maintenanceEnergy): maintenanceEnergy
        default: nil
        }
    }

}