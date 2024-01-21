import SwiftUI

public struct DemoView: View {
    public init() {
        
    }
    public var body: some View {
        Text("Demo")
    }
}

//public struct DemoView: View {
//    
//    @State var currentHealthModel: HealthModel = MockCurrentHealthModel
//    @State var pastHealthModel: HealthModel
//
//    @State var settingsStore: SettingsStore = SettingsStore.shared
//    
//    @State var showingCurrentHealthDetails = false
//    @State var showingPastHealthDetails = false
//    @State var showingUnits = false
//    
//    public init() {
//        let healthDetails: HealthDetails = fetchFromBackend(.pastHealthDetails)
//        let healthModel = HealthModel(
//            delegate: MockPastHealthModelDelegate(),
//            health: healthDetails
//        )
//        _pastHealthModel = State(initialValue: healthModel)
//    }
//    
//    public var body: some View {
//        NavigationStack {
//            Form {
//                Section {
//                    Button("Current Health Details") {
//                        showingCurrentHealthDetails = true
//                    }
//                    Button("Past Health Details") {
//                        showingPastHealthDetails = true
//                    }
//                }
//                Section {
//                    Button("Units") {
//                        showingUnits = true
//                    }
//                }
//            }
//            .navigationTitle("Health Details Demo")
//        }
//        .sheet(isPresented: $showingCurrentHealthDetails) { currentHealthSummary }
//        .sheet(isPresented: $showingPastHealthDetails) { pastHealthSummary }
//        .sheet(isPresented: $showingUnits) { unitsView }
//        .onAppear {
//            SettingsStore.configureAsMock()
//        }
//        .task {
//            Task {
//                try await currentHealthModel.refresh()
//            }
//        }
//    }
//    
//    var unitsView: some View {
//        NavigationStack {
//            UnitsView(settingsStore: settingsStore)
//        }
//    }
//    
//    var currentHealthSummary: some View {
//        NavigationStack {
//            HealthSummary(model: currentHealthModel)
//                .environment(settingsStore)
//        }
//    }
//    
//    var pastHealthSummary: some View {
//        NavigationStack {
//            HealthSummary(model: pastHealthModel)
//                .environment(settingsStore)
//        }
//    }
//}
