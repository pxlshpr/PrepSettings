import Foundation
import PrepShared

public struct HealthDetails: Hashable, Codable {
    
    public let date: Date
    
    public var maintenance = Maintenance()
    
    public var weight = Weight()
    public var height = Height()
    public var leanBodyMass = LeanBodyMass()
    public var fatPercentage = FatPercentage()
    public var pregnancyStatus: PregnancyStatus = .notSet
    
    public var dateOfBirthComponents: DateComponents?
    public var biologicalSex: BiologicalSex = .notSet
    public var smokingStatus: SmokingStatus = .notSet
    
    public var replacementsForMissing = ReplacementsForMissing()
}

extension HealthDetails {
    public struct ReplacementsForMissing: Hashable, Codable {
        public var datedWeight: DatedWeight?
        public var datedHeight: DatedHeight?
        public var datedLeanBodyMass: DatedLeanBodyMass?
        public var datedFatPercentage: DatedFatPercentage?
        public var datedPregnancyStatus: DatedPregnancyStatus?
        public var datedMaintenance: DatedMaintenance?
    }
}

extension HealthDetails.ReplacementsForMissing {
    func has(_ healthDetail: HealthDetail) -> Bool {
        switch healthDetail {
        case .weight:           datedWeight != nil
        case .height:           datedHeight != nil
        case .leanBodyMass:     datedLeanBodyMass != nil
        case .preganancyStatus: datedPregnancyStatus != nil
        case .fatPercentage:    datedFatPercentage != nil
        case .maintenance:      datedMaintenance != nil
        default:                false
        }
    }
}

extension HealthDetails {
    
    func extractReplacementsForMissing(from dict: [HealthDetail : DatedHealthData]) -> ReplacementsForMissing {
        ReplacementsForMissing(
            datedWeight: !hasSet(.weight) ? dict.datedWeight : nil,
            datedHeight: !hasSet(.height) ? dict.datedHeight : nil,
            datedLeanBodyMass: !hasSet(.leanBodyMass) ? dict.datedLeanBodyMass : nil,
            datedFatPercentage: !hasSet(.fatPercentage) ? dict.datedFatPercentage : nil,
            datedPregnancyStatus: !hasSet(.preganancyStatus) ? dict.datedPregnancyStatus : nil,
            datedMaintenance: !hasSet(.maintenance) ? dict.datedMaintenance : nil
        )
    }
}

public struct DatedWeight: Hashable, Codable {
    let date: Date
    var weight: HealthDetails.Weight
}

public struct DatedMaintenance: Hashable, Codable {
    let date: Date
    var maintenance: HealthDetails.Maintenance
}

public struct DatedHeight: Hashable, Codable {
    let date: Date
    var height: HealthDetails.Height
}

public struct DatedLeanBodyMass: Hashable, Codable {
    let date: Date
    var leanBodyMass: HealthDetails.LeanBodyMass
}

public struct DatedFatPercentage: Hashable, Codable {
    let date: Date
    var fatPercentage: HealthDetails.FatPercentage
}

public struct DatedPregnancyStatus: Hashable, Codable {
    let date: Date
    var pregnancyStatus: PregnancyStatus
}
