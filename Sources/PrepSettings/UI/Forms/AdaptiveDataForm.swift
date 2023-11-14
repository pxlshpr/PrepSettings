import SwiftUI
import PrepShared

struct AdaptiveDataForm: View {
    
    let dataPoint: AdaptiveDataPoint
    
    var body: some View {
        Form {
            
        }
        .navigationTitle(dataPoint.component.name)
    }
}

#Preview {
    NavigationStack {
        Text("Hello")
//        AdaptiveDataForm(dataPoint: MockDataPoints[0])
    }
}
