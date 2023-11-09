import SwiftUI
import PrepShared

struct HealthHeader: View {
    
    @Environment(HealthModel.self) var model: HealthModel

    let type: HealthType
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            HealthHeaderText(type.name)
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
