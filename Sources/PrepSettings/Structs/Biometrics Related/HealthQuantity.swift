import Foundation

public struct HealthQuantity: Hashable, Codable {
    public var source: HealthSource
    public var quantity: Quantity?
    
    public init(source: HealthSource, quantity: Quantity? = nil) {
        self.source = source
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
