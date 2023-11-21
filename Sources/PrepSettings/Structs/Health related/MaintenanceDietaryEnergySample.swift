import Foundation

public struct MaintenanceDietaryEnergySample: Hashable, Codable {
    var type: MaintenanceDietaryEnergySampleType
    var value: Double?

    public init(
        type: MaintenanceDietaryEnergySampleType,
        value: Double? = nil
    ) {
        self.type = type
        self.value = value
    }
}
