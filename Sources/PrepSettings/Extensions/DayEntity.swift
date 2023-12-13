import Foundation
import PrepShared

public extension DayEntity {
    var health: HealthDetails? {
        get {
            guard let healthData else { return nil }
            do {
                return try JSONDecoder().decode(HealthDetails.self, from: healthData)
            } catch {
                /// Error decoding, so set to nil
                self.healthData = nil
                return nil
            }
        }
        set {
            guard let newValue else {
                self.healthData = nil
                return
            }
            self.healthData = try! JSONEncoder().encode(newValue)
        }
    }
}
