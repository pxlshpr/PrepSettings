import Foundation

public struct HealthKitFetchSettings: Hashable, Codable {
    public var intervalType: HealthIntervalType = .average
    public var interval: HealthInterval = .init(3, .day)
    public var correction: Correction? = nil

    public struct Correction: Hashable, Codable {
        public let type: CorrectionType
        public let value: Double
    }
}
