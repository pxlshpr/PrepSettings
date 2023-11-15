import SwiftUI
import TipKit
import PrepSettings

@main
struct DemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear(perform: appeared)
        }
    }
    
    func appeared() {
        testAdaptiveHealthKitFetch()
    }
    
    func testAdaptiveHealthKitFetch() {
        guard !isPreview else { return }
        Task {
            guard let data = try await HealthStore.adaptiveWeightData(for: Date(fromDateString: "2023_02_26")!) else {
                print("No data")
                return
            }
            print(data)
        }
    }
}
