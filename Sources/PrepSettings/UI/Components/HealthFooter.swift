import SwiftUI
import PrepShared

struct HealthFooter<S: GenericSource>: View {
    
    let source: S
    let type: HealthType
    let hasQuantity: Bool
    
    @ViewBuilder
    var body: some View {
        if let string {
            Text(string)
        } else {
            EmptyView()
        }
    }
    
    var string: String? {
        switch source.isHealth {
        case true:
            healthFooterString(for: type, hasQuantity: hasQuantity)
        case false:
            nil
//            "Your will have to manually keep your \(type.abbreviation) updated here."
        }
    }
}

func healthFooterString(for type: HealthType, hasQuantity: Bool) -> String {
    if hasQuantity {
        "Your \(type.abbreviation) is synced with the Health app and will automatically re-calculate any dependent goals when it changes."
    } else {
        "Make sure you have allowed Prep to read your \(type.abbreviation) data in Settings > Privacy & Security > Health > Prep."
    }
}

