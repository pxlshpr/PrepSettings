import Foundation

public struct AdaptiveWeightDataPoints: Hashable, Codable {
    public let current: AdaptiveDataPoint?
    public let previous: AdaptiveDataPoint?
}

public extension AdaptiveWeightDataPoints {
    var delta: Double? {
        guard let current, let previous else { return nil }
        return current.value - previous.value
    }
}
