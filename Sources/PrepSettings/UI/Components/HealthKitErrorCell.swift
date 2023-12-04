import SwiftUI
import PrepShared

struct HealthKitErrorCell: View {
    let type: HealthType
    var body: some View {
        HStack(alignment: .top) {
//        HStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundStyle(Color.accentColor)
            VStack(alignment: .leading) {
                Text(heading)
                    .fontWeight(.semibold)
                Text(message)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                location
                Text(secondaryMessage)
                    .font(.system(.callout))
                    .foregroundStyle(Color(.secondaryLabel))
            }
        }
        .padding(.vertical, 10)
    }
    
    var location: some View {
//        TagView(string: locationString)
        HStack {
            Divider()
                .frame(minWidth: 2)
                .overlay { Color(.tertiaryLabel) }
            Text(locationString)
                .italic()
                .font(.callout)
                .foregroundStyle(.secondary)
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
    
    var locationString: String {
        "Settings > Privacy & Security > Health > Prep"
    }
}

#Preview {
    NavigationStack {
        Form {
            HealthKitErrorCell(type: .restingEnergy)
        }
    }
}
