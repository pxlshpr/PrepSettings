import Foundation
import PrepShared

public struct HealthDetails: Hashable, Codable {
    
    public let date: Date
    
    public var maintenance: Maintenance
    
    public var weight: Weight
    public var height: Height
    public var leanBodyMass: LeanBodyMass
    public var fatPercentage: FatPercentage
    public var pregnancyStatus: PregnancyStatus
    
    public var dateOfBirthComponents: DateComponents?
    public var biologicalSex: BiologicalSex
    public var smokingStatus: SmokingStatus
    
    public var replacementsForMissing: ReplacementsForMissing
    
    public init(
        date: Date,
        maintenance: Maintenance = Maintenance(),
        weight: Weight = Weight(),
        height: Height = Height(),
        leanBodyMass: LeanBodyMass = LeanBodyMass(),
        fatPercentage: FatPercentage = FatPercentage(),
        pregnancyStatus: PregnancyStatus = .notSet,
        dateOfBirthComponents: DateComponents? = nil,
        biologicalSex: BiologicalSex = .notSet,
        smokingStatus: SmokingStatus = .notSet,
        replacementsForMissing: ReplacementsForMissing = ReplacementsForMissing()
    ) {
        self.date = date
        self.maintenance = maintenance
        self.weight = weight
        self.height = height
        self.leanBodyMass = leanBodyMass
        self.fatPercentage = fatPercentage
        self.pregnancyStatus = pregnancyStatus
        self.dateOfBirthComponents = dateOfBirthComponents
        self.biologicalSex = biologicalSex
        self.smokingStatus = smokingStatus
        self.replacementsForMissing = replacementsForMissing
    }
}

extension HealthDetails {
    public struct ReplacementsForMissing: Hashable, Codable {
        public var datedWeight: DatedWeight?
        public var datedHeight: DatedHeight?
        public var datedLeanBodyMass: DatedLeanBodyMass?
        public var datedFatPercentage: DatedFatPercentage?
        public var datedPregnancyStatus: DatedPregnancyStatus?
        public var datedMaintenance: DatedMaintenance?
        
        public init(
            datedWeight: DatedWeight? = nil,
            datedHeight: DatedHeight? = nil,
            datedLeanBodyMass: DatedLeanBodyMass? = nil,
            datedFatPercentage: DatedFatPercentage? = nil,
            datedPregnancyStatus: DatedPregnancyStatus? = nil,
            datedMaintenance: DatedMaintenance? = nil
        ) {
            self.datedWeight = datedWeight
            self.datedHeight = datedHeight
            self.datedLeanBodyMass = datedLeanBodyMass
            self.datedFatPercentage = datedFatPercentage
            self.datedPregnancyStatus = datedPregnancyStatus
            self.datedMaintenance = datedMaintenance
        }
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
