import Foundation

public struct AdaptiveDietaryEnergyData: Hashable, Codable {
    static let DefaultNumberOfPoints = 7
    
    public let numberOfDays: Int
    public var points: [Int: AdaptiveDataPoint] = [:]
    
    init(numberOfDays: Int = DefaultNumberOfPoints) {
        self.numberOfDays = numberOfDays
    }
}

extension AdaptiveDietaryEnergyData: CustomStringConvertible {
    public var description: String {
        var string = ""
        for day in 0..<numberOfDays {
            if let point = points[day] {
                string += "[\(day)] → \(point.description)\n"
            } else {
                string += "[\(day)] → nil\n"
            }
        }
        return string
    }
}

public extension AdaptiveDietaryEnergyData {
    mutating func setPoint(at index: Int, with point: AdaptiveDataPoint) {
        points[index] = point
    }
    
    func point(at index: Int) -> AdaptiveDataPoint? {
        points[index]
    }
    
    func hasPoint(at index: Int) -> Bool {
        points[index] != nil
    }
}

public extension AdaptiveDietaryEnergyData {
    
    var average: Double? {
        let values = points.values.map { $0.value }
        guard !values.isEmpty else { return nil }
        let sum = values.reduce(0) { $0 + $1 }
        return Double(sum) / Double(values.count)
    }
    
    mutating func fillEmptyValuesWithAverages() {
        guard let average else { return }
        for i in 0..<numberOfDays {
            /// Only fill with average if there is no value for it
            guard points[i] == nil else { continue }
            points[i] = .init(.averaged, average)
        }
    }
}
