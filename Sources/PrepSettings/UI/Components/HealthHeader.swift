import SwiftUI
import PrepShared

struct HealthHeader: View {
    
    @Environment(HealthModel.self) var model: HealthModel

    let type: HealthType
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(type.name)
                .font(.title3)
                .textCase(.none)
                .foregroundStyle(Color(.label))
                .fontWeight(.semibold)
            Spacer()
            removeButton
        }
    }
    
    var removeButton: some View {
        Button("Remove") {
            withAnimation {
                model.remove(type)
            }
        }
        .textCase(.none)
    }
}
