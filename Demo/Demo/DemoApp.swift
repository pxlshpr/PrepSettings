import SwiftUI
import TipKit

@main
struct DemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    init() {
        // Optional configure tips for testing.
        setupTipsForTesting()

        // Configure and load all tips in the app.
        try? Tips.configure()
    }
    
    private func setupTipsForTesting() {
        // Show all defined tips in the app.
//        Tips.showAllTipsForTesting()

        do {

            // Show some tips, but not all.
            // try? Tips.showTipsForTesting([tip1, tip2, tip3])

            // Hide all tips defined in the app.
            // try? Tips.hideAllTipsForTesting()

            // Purge all TipKit-related data.
            try Tips.resetDatastore()
        } catch {
            print(error)
        }
    }
}
