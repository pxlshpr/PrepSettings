import Foundation
import PrepShared

protocol GenericQuantity {
    var value: Double { get }
    var prefix: String? { get }
}

extension Quantity: GenericQuantity {
    var prefix: String? {
        date?.biometricFormat
    }
}
