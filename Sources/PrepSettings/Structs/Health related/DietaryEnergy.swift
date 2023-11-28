import Foundation

public struct DietaryEnergy: Hashable, Codable {
    public static let DefaultNumberOfSamples = 7
    public var samples: [DietaryEnergySample]
    
    public init(
        samples: [DietaryEnergySample] = Array.init(
            repeating: DietaryEnergySample(type: .healthKit),
            count: DefaultNumberOfSamples
        )
    ) {
        self.samples = samples
    }
}

extension DietaryEnergy {
    //TODO: We need type of dietary energy to be passed in too
    //TODO: We need to show image in cells
    mutating func setValues(
        _ values: MaintenanceValues,
        _ date: Date,
        _ interval: HealthInterval
    ) {
        let numberOfDays = interval.numberOfDays
        samples = Array.init(
            repeating: DietaryEnergySample(type: .healthKit),
            count: numberOfDays
        )
        for i in 0..<numberOfDays {
            let date = date.moveDayBy(-i)
            samples[i].value = values.dietaryEnergyInKcal(for: date)
            if let type = values.dietaryEnergyType(for: date) {
                samples[i].type = type
            }
        }
    }
}

public extension DietaryEnergy {
    mutating func setSample(at index: Int, with sample: DietaryEnergySample) {
        samples[index] = sample
    }
    
    func sample(at index: Int) -> DietaryEnergySample? {
        samples[index]
    }
    
    func hasSample(at index: Int) -> Bool {
        samples[index].value != nil
    }
}

public extension DietaryEnergy {
    
    var average: Double? {
        let values = samples
            .compactMap { $0.value }
        guard !values.isEmpty else { return nil }
        let sum = values.reduce(0) { $0 + $1 }
        return Double(sum) / Double(values.count)
    }
    
    mutating func fillEmptyValuesWithAverages() {
        guard let average else { return }
        for i in 0..<samples.count {
            /// Only fill with average if there is no value for it
            guard samples[i].value == nil else { continue }
            samples[i] = .init(
                type: .average,
                value: average
            )
        }
    }
    
    var isEmpty: Bool {
        samples.contains(where: { $0.value == nil })
    }
    
    var total: Double? {
        guard !isEmpty else { return nil }
        return samples
            .compactMap { $0.value }
            .reduce(0) { $0 + $1 }
    }
}

extension DietaryEnergy {
    func healthKitDatesRange(for date: Date) -> ClosedRange<Date>? {
        guard let firstIndex = samples.firstIndex(where: { $0.type == .healthKit }),
              let lastIndex = samples.lastIndex(where: { $0.type == .healthKit })
        else { return nil }

        /// Older date would be further down the list since indexes are number of days **prior** to the date provided
        let older = date.moveDayBy(-lastIndex)
        let newer = date.moveDayBy(-firstIndex)
        return older...newer
    }
}
