import Foundation
import PrepShared
import HealthKit

extension HealthDetails {
    public struct Weight: Hashable, Codable {
        public var weightInKg: Double?
        public var measurements: [WeightMeasurement]
        public var deletedHealthKitMeasurements: [WeightMeasurement]
        
        public init(
            weightInKg: Double? = nil,
            measurements: [WeightMeasurement] = [],
            deletedHealthKitMeasurements: [WeightMeasurement] = []
        ) {
            self.weightInKg = weightInKg
            self.measurements = measurements
            self.deletedHealthKitMeasurements = deletedHealthKitMeasurements
        }
    }
}

extension Array where Element == HealthDetails.Weight {
    var averageValue: Double? {
        compactMap{ $0.weightInKg }.average
    }
}

extension HealthDetails.Weight {
    mutating func addHealthKitSample(_ sample: HKQuantitySample, using dailyMeasurementType: DailyMeasurementType) {
        guard !measurements.contains(where: { $0.healthKitUUID == sample.uuid }),
              !deletedHealthKitMeasurements.contains(where: { $0.healthKitUUID == sample.uuid })
        else {
            return
        }
        measurements.append(WeightMeasurement(healthKitQuantitySample: sample))
        measurements.sort()
        weightInKg = measurements.dailyMeasurement(for: dailyMeasurementType)
    }

    func valueString(in unit: BodyMassUnit) -> String {
        weightInKg.valueString(convertedFrom: .kg, to: unit)
    }
}

