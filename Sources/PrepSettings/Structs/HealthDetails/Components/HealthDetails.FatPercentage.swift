import Foundation
import PrepShared
import HealthKit

extension HealthDetails {
    public struct FatPercentage: Hashable, Codable {
        public var fatPercentage: Double? = nil
        public var measurements: [FatPercentageMeasurement]
        public var deletedHealthKitMeasurements: [FatPercentageMeasurement]
        
        public init(
            fatPercentage: Double? = nil,
            measurements: [FatPercentageMeasurement] = [],
            deletedHealthKitMeasurements: [FatPercentageMeasurement] = []
        ) {
            self.fatPercentage = fatPercentage
            self.measurements = measurements
            self.deletedHealthKitMeasurements = deletedHealthKitMeasurements
        }
    }
}

extension HealthDetails.FatPercentage {
    mutating func addHealthKitSample(_ sample: HKQuantitySample, using dailyMeasurementType: DailyMeasurementType) {
        guard !measurements.contains(where: { $0.healthKitUUID == sample.uuid }),
              !deletedHealthKitMeasurements.contains(where: { $0.healthKitUUID == sample.uuid })
        else {
            return
        }
        measurements.append(FatPercentageMeasurement(healthKitQuantitySample: sample))
        measurements.sort()
        fatPercentage = measurements.dailyMeasurement(for: dailyMeasurementType)
    }

    var valueString: String {
        guard let fatPercentage else { return NotSetString }
        return "\(fatPercentage.cleanHealth) %"
    }
}
