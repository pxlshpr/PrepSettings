import Foundation

public struct HealthQuantity: Hashable, Codable {
    public var source: HealthSource
    public var isDailyAverage: Bool
    public var quantity: Quantity?
    
    public init(
        source: HealthSource,
        isDailyAverage: Bool = false,
        quantity: Quantity? = nil
    ) {
        self.source = source
        self.isDailyAverage = isDailyAverage
        self.quantity = quantity
    }
}

public extension HealthQuantity {
    
    mutating func removeDateIfNotNeeded() {
        switch source {
        case .healthKit:       break
        case .userEntered:  quantity?.date = nil
        }
    }
}
