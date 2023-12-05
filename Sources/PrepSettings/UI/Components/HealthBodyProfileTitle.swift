import SwiftUI

struct HealthBodyProfileTitle: View {
    
    @Bindable var model: HealthModel
    
    init(_ model: HealthModel) {
        self.model = model
    }
    
    @ViewBuilder
    var body: some View {
        if model.health.hasType(.maintenance) {
            content
                .padding(.top)
        } else {
            content
        }
    }
    
    var content: some View {
        Text("Body Profile")
            .font(.title2)
            .textCase(.none)
            .foregroundStyle(Color(.label))
            .fontWeight(.bold)
    }
}
