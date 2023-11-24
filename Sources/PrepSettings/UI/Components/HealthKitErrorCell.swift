import SwiftUI
import PrepShared

struct HealthKitErrorCell: View {
    let type: HealthType
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundStyle(Color.accentColor)
            VStack(alignment: .leading) {
                Text(heading)
                    .fontWeight(.semibold)
                Text(message)
                    .font(.system(.callout))
                    .foregroundStyle(.secondary)
                TagView(string: location)
                Text(secondaryMessage)
                    .font(.system(.callout))
                    .foregroundStyle(Color(.secondaryLabel))
            }
        }
    }
    
    var heading: String {
        "Data unavailable"
    }
    
    var message: String {
        "Check that you have allowed Prep to read your \(type.abbreviation) in:"
    }
    
    var secondaryMessage: String {
        "If allowed, then there may be no \(type.abbreviation) data."
    }
    
    var location: String {
        "Settings > Privacy & Security > Health > Prep"
    }
}
