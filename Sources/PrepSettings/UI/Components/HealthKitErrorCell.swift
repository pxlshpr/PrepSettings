import SwiftUI
import PrepShared

struct HealthKitErrorCell: View {
    let type: HealthType
    var body: some View {
        Text(message)
            .foregroundStyle(.secondary)
    }
    
    var message: String {
        "⚠️ Check that you have allowed Prep to read your \(type.abbreviation) data in Settings > Privacy & Security > Health > Prep."
    }
}
