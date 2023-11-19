import Foundation

public struct DietaryEnergy: Hashable, Codable {
    public static let DefaultNumberOfSamples = 7
    public var samples: [MaintenanceSample]
    
    public init(
        samples: [MaintenanceSample] = Array.init(
            repeating: MaintenanceSample(type: .userEntered),
            count: DefaultNumberOfSamples
        )
    ) {
        self.samples = samples
    }
}

extension DietaryEnergy: CustomStringConvertible {
    public var description: String {
        var string = ""
        for i in 0..<samples.count {
            string += "[\(i)] → \(samples[i].description)\n"
        }
        return string
    }
}

public extension DietaryEnergy {
    mutating func setSample(at index: Int, with sample: MaintenanceSample) {
        samples[index] = sample
    }
    
    func sample(at index: Int) -> MaintenanceSample? {
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
                type: .averaged,
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
