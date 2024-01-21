import Foundation
import HealthKit
import PrepShared

extension HealthDetails {
    public struct Height: Hashable, Codable {
        public var heightInCm: Double?
        public var measurements: [HeightMeasurement]
        public var deletedHealthKitMeasurements: [HeightMeasurement]
        
        public init(
            heightInCm: Double? = nil,
            measurements: [HeightMeasurement] = [],
            deletedHealthKitMeasurements: [HeightMeasurement] = []
        ) {
            self.heightInCm = heightInCm
            self.measurements = measurements
            self.deletedHealthKitMeasurements = deletedHealthKitMeasurements
        }
    }
}

extension HealthDetails.Height {
    
    mutating func addHealthKitSample(_ sample: HKQuantitySample, using dailyMeasurementType: DailyMeasurementType) {
        guard !measurements.contains(where: { $0.healthKitUUID == sample.uuid }),
              !deletedHealthKitMeasurements.contains(where: { $0.healthKitUUID == sample.uuid })
        else {
            return
        }
        measurements.append(HeightMeasurement(healthKitQuantitySample: sample))
        measurements.sort()
        heightInCm = measurements.dailyMeasurement(for: dailyMeasurementType)
    }
    
    func valueString(in unit: HeightUnit) -> String {
        heightInCm.valueString(convertedFrom: .cm, to: unit)
    }
}
