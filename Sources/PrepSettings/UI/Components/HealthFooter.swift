import SwiftUI
import PrepShared

struct HealthFooter<S: GenericSource>: View {
    
    let source: S
    let type: HealthType
    let hasQuantity: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            if let reason = type.reason {
                Text(reason)
            }
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
