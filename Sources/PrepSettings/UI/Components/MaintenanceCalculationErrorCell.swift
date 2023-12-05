import SwiftUI
import PrepShared

/// [ ] If there is no weight data—show "
/// [ ] When this is the first time user is using this, let them
/// [ ] Always give the user
struct MaintenanceCalculationErrorCell: View {
    
    let error: MaintenanceCalculationError
    
    init(_ error: MaintenanceCalculationError) {
        self.error = error
    }
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "info.circle")
                .font(.system(size: 50))
                .foregroundStyle(Color.accentColor)
            VStack(alignment: .leading) {
                Text(error.title)
                    .fontWeight(.semibold)
                Text(error.message  + " " + secondaryMessage)
                    .font(.system(.callout))
                    .foregroundStyle(.secondary)
//                Divider()
//                Text(secondaryMessage)
//                    .font(.system(.callout))
//                    .foregroundStyle(Color(.secondaryLabel))
//                Divider()
//                setDataButton
            }
        }
    }
    
//    var setDataButton: some View {
//        Button {
//            showingAdaptiveDetails = true
//        } label: {
//            Text("Show Data")
//                .fontWeight(.semibold)
//                .foregroundStyle(Color.accentColor)
//        }
//        .buttonStyle(.plain)
//        .padding(.top, 5)
//    }
    
    var secondaryMessage: String {
        "Your estimated maintenance energy is being used instead."
    }
}
