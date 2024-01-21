import Foundation
import HealthKit

public struct LeanBodyMassMeasurement: Hashable, Identifiable, Codable {
    public let id: UUID
    public let source: MeasurementSource
    public let healthKitUUID: UUID?
    public let equation: LeanBodyMassAndFatPercentageEquation?
    public let date: Date
    public var leanBodyMassInKg: Double
    public let isConvertedFromFatPercentage: Bool

    init(
        id: UUID,
        date: Date,
        value: Double,
        healthKitUUID: UUID?
    ) {
        self.id = id
        self.source = if healthKitUUID != nil {
            .healthKit
        } else {
            .manual
        }
        self.healthKitUUID = healthKitUUID
        self.equation = nil
        self.date = date
        self.leanBodyMassInKg = value
        self.isConvertedFromFatPercentage = false
    }
    
    init(
        id: UUID = UUID(),
        date: Date,
        leanBodyMassInKg: Double,
        source: MeasurementSource,
        healthKitUUID: UUID?,
        equation: LeanBodyMassAndFatPercentageEquation? = nil,
        isConvertedFromFatPercentage: Bool = false
    ) {
        self.id = id
        self.source = source
        self.healthKitUUID = healthKitUUID
        self.date = date
        self.equation = equation
        self.leanBodyMassInKg = leanBodyMassInKg
        self.isConvertedFromFatPercentage = isConvertedFromFatPercentage
    }
}

extension Array where Element == LeanBodyMassMeasurement {
    var nonConverted: [LeanBodyMassMeasurement] {
        filter { !$0.isConvertedFromFatPercentage }
    }
    
    var converted: [LeanBodyMassMeasurement] {
        filter { $0.isConvertedFromFatPercentage }
    }
}
