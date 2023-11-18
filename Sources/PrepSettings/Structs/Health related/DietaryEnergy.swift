import Foundation

public struct DietaryEnergy: Hashable, Codable {
    static let DefaultNumberOfPoints = 7
    
    public let numberOfDays: Int
    public var samples: [Int: MaintenanceSample] = [:]
    
    init(numberOfDays: Int = DefaultNumberOfPoints) {
        self.numberOfDays = numberOfDays
    }
}

extension DietaryEnergy: CustomStringConvertible {
    public var description: String {
        var string = ""
        for day in 0..<numberOfDays {
            if let point = samples[day] {
                string += "[\(day)] → \(point.description)\n"
            } else {
                string += "[\(day)] → nil\n"
            }
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
        samples[index] != nil
    }
}

public extension DietaryEnergy {
    
    var average: Double? {
        let values = samples.values.map { $0.value }
        guard !values.isEmpty else { return nil }
        let sum = values.reduce(0) { $0 + $1 }
        return Double(sum) / Double(values.count)
    }
    
    mutating func fillEmptyValuesWithAverages() {
        guard let average else { return }
        for i in 0..<numberOfDays {
            /// Only fill with average if there is no value for it
            guard samples[i] == nil else { continue }
            samples[i] = .init(
                type: .averaged,
                value: average
            )
        }
    }
}
