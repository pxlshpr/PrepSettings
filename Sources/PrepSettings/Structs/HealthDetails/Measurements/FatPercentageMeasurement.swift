import Foundation
import HealthKit
import PrepShared

//public struct FatPercentageMeasurement: Hashable, Identifiable, Codable {
//    public let id: UUID
//    public let source: MeasurementSource
//    public let healthKitUUID: UUID?
//    public let equation: LeanBodyMassAndFatPercentageEquation?
//    public let date: Date
//    public var percent: Double
//    public let isConvertedFromLeanBodyMass: Bool
//
//    init(
//        id: UUID,
//        date: Date,
//        value: Double,
//        healthKitUUID: UUID?
//    ) {
//        self.id = id
//        self.source = if healthKitUUID != nil {
//            .healthKit
//        } else {
//            .manual
//        }
//        self.healthKitUUID = healthKitUUID
//        self.equation = nil
//        self.date = date
//        self.percent = value
//        self.isConvertedFromLeanBodyMass = false
//    }
//    
//    init(
//        id: UUID = UUID(),
//        date: Date,
//        percent: Double,
//        source: MeasurementSource,
//        healthKitUUID: UUID?,
//        equation: LeanBodyMassAndFatPercentageEquation? = nil,
//        isConvertedFromLeanBodyMass: Bool = false
//    ) {
//        self.id = id
//        self.source = source
//        self.date = date
//        self.percent = percent
//        self.equation = equation
//        self.isConvertedFromLeanBodyMass = isConvertedFromLeanBodyMass
//        self.healthKitUUID = healthKitUUID
//    }
//}

extension FatPercentageMeasurement {
    init(healthKitQuantitySample sample: HKQuantitySample) {
        self.init(
            id: UUID(),
            date: sample.date,
            percent: sample.quantity.doubleValue(for: .percent()) * 100.0, /// Apple Health stores percents in decimal form,
            source: .healthKit,
            healthKitUUID: sample.uuid,
            equation: nil,
            isConvertedFromLeanBodyMass: false
        )
//        self.id = UUID()
//        self.source = .healthKit
//        self.healthKitUUID = sample.uuid
//        self.equation = nil
//        self.date = sample.date
//        self.percent = sample.quantity.doubleValue(for: .percent()) * 100.0 /// Apple Health stores percents in decimal form
//        self.isConvertedFromLeanBodyMass = false
    }
}

extension Array where Element == FatPercentageMeasurement {
    var nonConverted: [FatPercentageMeasurement] {
        filter { !$0.isConvertedFromLeanBodyMass }
    }
    
    var converted: [FatPercentageMeasurement] {
        filter { $0.isConvertedFromLeanBodyMass }
    }
}

extension FatPercentageMeasurement {
    func isHealthKitCounterpartToAMeasurement(in leanBodyMass: HealthDetails.LeanBodyMass) -> Bool {
        guard source.isFromHealthKit else { return false }
        return leanBodyMass.measurements.contains(where: {
            $0.isFromHealthKit && $0.date.equalsIgnoringSeconds(self.date)
        })
    }
}

extension LeanBodyMassMeasurement {
    func isHealthKitCounterpartToAMeasurement(in fatPercentage: HealthDetails.FatPercentage) -> Bool {
        guard source.isFromHealthKit else { return false }
        return fatPercentage.measurements.contains(where: {
            $0.isFromHealthKit && $0.date.equalsIgnoringSeconds(self.date)
        })
    }
}
