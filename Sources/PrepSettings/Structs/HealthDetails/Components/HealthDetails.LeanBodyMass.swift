import Foundation
import PrepShared
import HealthKit

//extension HealthDetails {
//    public struct LeanBodyMass: Hashable, Codable {
//        public var leanBodyMassInKg: Double? = nil
//        public var measurements: [LeanBodyMassMeasurement]
//        public var deletedHealthKitMeasurements: [LeanBodyMassMeasurement]
//        
//        public init(
//            leanBodyMassInKg: Double? = nil,
//            measurements: [LeanBodyMassMeasurement] = [],
//            deletedHealthKitMeasurements: [LeanBodyMassMeasurement] = []
//        ) {
//            self.leanBodyMassInKg = leanBodyMassInKg
//            self.measurements = measurements
//            self.deletedHealthKitMeasurements = deletedHealthKitMeasurements
//        }
//    }
//}

extension HealthDetails.LeanBodyMass {
    mutating func addHealthKitSample(_ sample: HKQuantitySample, using dailyMeasurementType: DailyMeasurementType) {
        guard !measurements.contains(where: { $0.healthKitUUID == sample.uuid }),
              !deletedHealthKitMeasurements.contains(where: { $0.healthKitUUID == sample.uuid })
        else {
            return
        }
        measurements.append(LeanBodyMassMeasurement(healthKitQuantitySample: sample))
        measurements.sort()
        leanBodyMassInKg = measurements.dailyMeasurement(for: dailyMeasurementType)
    }
    
    func valueString(in unit: BodyMassUnit) -> String {
        leanBodyMassInKg.valueString(convertedFrom: .kg, to: unit)
    }
}
