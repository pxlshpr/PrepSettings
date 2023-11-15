import XCTest
@testable import PrepSettings

final class AdaptiveDataPointsTests: XCTestCase {
    func testDietaryEnergyDataPoints() throws {
        var dietaryEnergy = AdaptiveDietaryEnergyData()
        dietaryEnergy.setPoint(at: 0, with: .init(.healthKit, 2000))
        dietaryEnergy.setPoint(at: 1, with: .init(.healthKit, 2000))
        dietaryEnergy.setPoint(at: 3, with: .init(.healthKit, 3000))
        /// We've only set 3 points
        XCTAssert(dietaryEnergy.points.keys.count == 3)
        
        print("⬅️ Before")
        print(dietaryEnergy)
        dietaryEnergy.fillEmptyValuesWithAverages()
        print("➡️ After fillEmptyValuesWithAverages()")
        print(dietaryEnergy)

        /// We've only set 3 points
        XCTAssert(dietaryEnergy.points.keys.count == AdaptiveDietaryEnergyDataPoints.DefaultNumberOfPoints)
    }
}
