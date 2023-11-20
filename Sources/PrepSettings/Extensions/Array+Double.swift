import Foundation

extension Array where Element == Double {
    var averageValue: Double? {
        guard !isEmpty else { return nil }
        let sum = self
            .reduce(0, +)
        return sum / Double(count)
    }
}
