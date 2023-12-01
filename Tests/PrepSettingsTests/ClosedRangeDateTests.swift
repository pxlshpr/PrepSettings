import XCTest
@testable import PrepSettings
import PrepShared

final class ClosedRangeDateTests: XCTestCase {
    func testString() throws {
        let testCases: [(ClosedRange<Date>, String)] = [
            (d("2023_12_02")...d("2023_12_15"), "2 – 15 Dec"),
            (d("2022_12_02")...d("2022_12_15"), "2 – 15 Dec 2022"),
            (d("2022_11_05")...d("2022_12_02"), "5 Nov – 2 Dec 2022"),
            (d("2021_11_05")...d("2022_12_02"), "5 Nov 2021 – 2 Dec 2022"),
        ]
        
        for (range, string) in testCases {
            XCTAssertEqual(range.string, string)
        }
    }
}

func d(_ string: String) -> Date {
    Date(fromDateString: string)!
}
