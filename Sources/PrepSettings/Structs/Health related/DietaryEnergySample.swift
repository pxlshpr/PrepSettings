import PrepShared

public struct DietaryEnergySample: Hashable, Codable {
    var type: DietaryEnergySampleType
    var value: Double?

    public init(
        type: DietaryEnergySampleType,
        value: Double? = nil
    ) {
        self.type = type
        self.value = value
    }
}

extension DietaryEnergySample {
    func value(in unit: EnergyUnit) -> Double? {
        guard let value else { return nil }
        return EnergyUnit.kcal.convert(value, to: unit)
    }
}
