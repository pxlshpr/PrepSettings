import SwiftUI
import TipKit
import PrepSettings

@main
struct DemoApp: App {
    var body: some Scene {
        WindowGroup {
            DemoView()
//            ContentView()
                .onAppear(perform: appeared)
        }
    }
    
    func appeared() {
        testAdaptiveHealthKitFetch()
    }
    
    func testAdaptiveHealthKitFetch() {
        guard !isPreview else { return }
        Task {
//            let date = Date(fromDateString: "2023_02_26")!
//            let maintenance = try await HealthStore.adaptiveMaintenanceEnergy(
//                energyUnit: .kcal,
//                bodyMassUnit: .kg,
//                on: date,
//                interval: .init(1, .week),
//                weightMovingAverageDays: 7
//            )
//            print(maintenance)
//            let data = try await HealthStore.adaptiveWeightData(on: date)!
//            print(data)
        }
    }
}
