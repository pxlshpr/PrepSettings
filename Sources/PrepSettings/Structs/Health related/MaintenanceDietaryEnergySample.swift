import PrepShared

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

extension MaintenanceDietaryEnergySample {
    func value(in unit: EnergyUnit) -> Double? {
        guard let value else { return nil }
        return EnergyUnit.kcal.convert(value, to: unit)
    }
}
