import Foundation
import PrepShared

extension HealthDetails {
    
    func data(for healthDetail: HealthDetail) -> Any? {
        return switch healthDetail {
        case .maintenance:      maintenance
        case .age:              dateOfBirthComponents
        case .biologicalSex:    biologicalSex
        case .weight:           weight
        case .leanBodyMass:     leanBodyMass
        case .height:           height
        case .preganancyStatus: pregnancyStatus
        case .smokingStatus:    smokingStatus
        case .fatPercentage:    fatPercentage
        }
    }
    
    func hasSet(_ healthDetail: HealthDetail) -> Bool {
        switch healthDetail {
        case .maintenance:      maintenance.kcal != nil
        case .age:              ageInYears != nil
        case .biologicalSex:    biologicalSex != .notSet
        case .weight:           weight.weightInKg != nil
        case .leanBodyMass:     leanBodyMass.leanBodyMassInKg != nil
        case .fatPercentage:    fatPercentage.fatPercentage != nil
        case .height:           height.heightInCm != nil
        case .preganancyStatus: pregnancyStatus != .notSet
        case .smokingStatus:    smokingStatus != .notSet
        }
    }

//    func secondaryValueString(
//        for healthDetail: HealthDetail,
//        _ settingsProvider: SettingsProvider
//    ) -> String? {
//        switch healthDetail {
//        case .leanBodyMass:
//            leanBodyMass.secondaryValueString()
//        default:
//            nil
//        }
//    }

    func valueString(
        for healthDetail: HealthDetail,
        _ provider: Provider
    ) -> String {
        switch healthDetail {
        case .age:
            if let ageInYears {
                "\(ageInYears)"
            } else {
                NotSetString
            }
        case .biologicalSex:
            biologicalSex.name
        case .weight:
            weight.valueString(in: provider.bodyMassUnit)
        case .leanBodyMass:
            leanBodyMass.valueString(in: provider.bodyMassUnit)
        case .fatPercentage:
            fatPercentage.valueString
        case .height:
            height.valueString(in: provider.heightUnit)
        case .preganancyStatus:
            pregnancyStatus.name
        case .smokingStatus:
            smokingStatus.name
        case .maintenance:
            maintenance.valueString(in: provider.energyUnit)
        }
    }
}

extension HealthDetails {
    func containsChangesInSyncableMeasurements(from other: HealthDetails) -> Bool {
        weight != other.weight
        || height != other.height
        || leanBodyMass != other.leanBodyMass
        || fatPercentage != other.fatPercentage
    }
}

extension HealthDetails {
    var adaptiveMaintenanceIntervalString: String {
        let startDate = maintenance.adaptive.interval.startDate(with: date)
        return "\(startDate.shortDateString) to \(date.shortDateString)"
    }
}

extension HealthDetails {
    var currentOrLatestWeightInKg: Double? {
        weight.weightInKg ?? replacementsForMissing.datedWeight?.weight.weightInKg
    }
    
    var currentOrLatestLeanBodyMassInKg: Double? {
        leanBodyMass.leanBodyMassInKg ?? replacementsForMissing.datedLeanBodyMass?.leanBodyMass.leanBodyMassInKg
    }
    
    var currentOrLatestHeightInCm: Double? {
        height.heightInCm ?? replacementsForMissing.datedHeight?.height.heightInCm
    }
    
    var hasIncompatibleLeanBodyMassAndFatPercentageWithWeight: Bool {
        guard let fatPercentage = currentOrLatestFatPercentage,
              let weight = currentOrLatestWeightInKg,
              let leanBodyMass = currentOrLatestLeanBodyMassInKg else {
            return false
        }
        
        let calculatedLeanBodyMass = calculateLeanBodyMass(
            fatPercentage: fatPercentage,
            weightInKg: weight
        )
        return calculatedLeanBodyMass != leanBodyMass
    }
    
    var currentOrLatestFatPercentage: Double? {
        fatPercentage.fatPercentage ?? replacementsForMissing.datedFatPercentage?.fatPercentage.fatPercentage
    }
}
