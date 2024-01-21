import Foundation
import HealthKit

public struct HeightMeasurement: Hashable, Identifiable, Codable {
    public let id: UUID
    public let healthKitUUID: UUID?
    public let date: Date
    public let heightInCm: Double
    
    init(
        id: UUID = UUID(),
        date: Date,
        heightInCm: Double,
        healthKitUUID: UUID? = nil
    ) {
        self.init(id: id, date: date, value: heightInCm, healthKitUUID: healthKitUUID)
    }

    init(
        id: UUID = UUID(),
        date: Date,
        value: Double,
        healthKitUUID: UUID? = nil
    ) {
        self.id = id
        self.healthKitUUID = healthKitUUID
        self.date = date
        self.heightInCm = value
    }    
}

