import XCTest
@testable import PrepSettings
import PrepShared
import SwiftSugar

final class HealthDetailsTests: XCTestCase {
    
    func testRefresh_Maintenance_10_Days() async throws {
        
        let NumberOfDays = 10
        
        var maintenance = HealthDetails.Maintenance()
        maintenance.adaptive.weightChange.current = WeightSample(
            value: 92.125,
            source: .movingAverage,
            isDailyAverage: false,
            movingAverage: .init(
                interval: .init(1, .week),
                weights: [
                    weight(0, NumberOfDays),
                    weight(1, NumberOfDays),
                    weight(2, NumberOfDays),
                    weight(3, NumberOfDays),
                    weight(4, NumberOfDays),
                    weight(5, NumberOfDays),
                    weight(6, NumberOfDays)
                ]
            )
        )
        maintenance.adaptive.weightChange.previous = WeightSample(
            value: 95.06666667,
            source: .movingAverage,
            isDailyAverage: false,
            movingAverage: .init(
                interval: .init(1, .week),
                weights: [
                    weight(7, NumberOfDays),
                    weight(8, NumberOfDays),
                    weight(9, NumberOfDays),
                    weight(10, NumberOfDays),
                    weight(11, NumberOfDays),
                    weight(12, NumberOfDays),
                    weight(13, NumberOfDays)
                ]
            )
        )
        
        let testCase = HealthDetails(
            date: Date.now.moveDayBy(-NumberOfDays),
            maintenance: maintenance
        )
        
        
        let healthModel = HealthModel(
            delegate: TestHealthModelDelegate(),
            fetchCurrentHealthHandler: { testCase }
        )
        
        /// Sleep to let the fetch handler actually fetch the HealthDetails
        try await sleepTask(1.0, tolerance: 0.1)
        
        var currentWeights = healthModel.health.maintenance?.adaptive.weightChange.current.movingAverage?.weights ?? []
        var previousWeights = healthModel.health.maintenance?.adaptive.weightChange.previous.movingAverage?.weights ?? []
        
        XCTAssertEqual(currentWeights[0], weight(0, NumberOfDays))
        XCTAssertEqual(currentWeights[4], weight(4, NumberOfDays))
        XCTAssertEqual(previousWeights[3], weight(10, NumberOfDays))
        
        try await healthModel.refresh()
        
        currentWeights = healthModel.health.maintenance?.adaptive.weightChange.current.movingAverage?.weights ?? []
        previousWeights = healthModel.health.maintenance?.adaptive.weightChange.previous.movingAverage?.weights ?? []
        
        for weight in currentWeights {
            XCTAssertEqual(weight, Empty)
        }
        XCTAssertEqual(previousWeights[3], weight(0, NumberOfDays))
    }
    
    func testRefresh_Maintenance_3_Days() async throws {
        
        let NumberOfDays = 3
        
        var maintenance = HealthDetails.Maintenance()
        maintenance.adaptive.weightChange.current = WeightSample(
            value: 92.125,
            source: .movingAverage,
            isDailyAverage: false,
            movingAverage: .init(
                interval: .init(1, .week),
                weights: [
                    weight(0, NumberOfDays),
                    weight(1, NumberOfDays),
                    weight(2, NumberOfDays),
                    weight(3, NumberOfDays),
                    weight(4, NumberOfDays),
                    weight(5, NumberOfDays),
                    weight(6, NumberOfDays)
                ]
            )
        )
        maintenance.adaptive.weightChange.previous = WeightSample(
            value: 95.06666667,
            source: .movingAverage,
            isDailyAverage: false,
            movingAverage: .init(
                interval: .init(1, .week),
                weights: [
                    weight(7, NumberOfDays),
                    weight(8, NumberOfDays),
                    weight(9, NumberOfDays),
                    weight(10, NumberOfDays),
                    weight(11, NumberOfDays),
                    weight(12, NumberOfDays),
                    weight(13, NumberOfDays)
                ]
            )
        )
        
        let testCase = HealthDetails(
            date: Date.now.moveDayBy(-NumberOfDays),
            maintenance: maintenance
        )
        
        
        let healthModel = HealthModel(
            delegate: TestHealthModelDelegate(),
            fetchCurrentHealthHandler: { testCase }
        )
        
        /// Sleep to let the fetch handler actually fetch the HealthDetails
        try await sleepTask(1.0, tolerance: 0.1)
        
        var currentWeights = healthModel.health.maintenance?.adaptive.weightChange.current.movingAverage?.weights ?? []
        var previousWeights = healthModel.health.maintenance?.adaptive.weightChange.previous.movingAverage?.weights ?? []
        
        XCTAssertEqual(currentWeights[0], weight(0, NumberOfDays))
        XCTAssertEqual(currentWeights[4], weight(4, NumberOfDays))
        XCTAssertEqual(previousWeights[3], weight(10, NumberOfDays))
        
        try await healthModel.refresh()
        
        currentWeights = healthModel.health.maintenance?.adaptive.weightChange.current.movingAverage?.weights ?? []
        previousWeights = healthModel.health.maintenance?.adaptive.weightChange.previous.movingAverage?.weights ?? []
        
        XCTAssertEqual(currentWeights[0 + NumberOfDays], weight(0, NumberOfDays))
        XCTAssertEqual(previousWeights[0 + NumberOfDays], weight(7, NumberOfDays))
        XCTAssertEqual(previousWeights[3 + NumberOfDays], weight(10, NumberOfDays))
    }

    func testRefresh_Maintenance_3_Days_Overlap() async throws {

        let NumberOfDays = 3

        var maintenance = HealthDetails.Maintenance()
        maintenance.adaptive.interval = .init(3, .day)
        maintenance.adaptive.weightChange.current = WeightSample(
            value: 92.125,
            source: .movingAverage,
            isDailyAverage: false,
            movingAverage: .init(
                interval: .init(1, .week),
                weights: [
                    weight(0, NumberOfDays),
                    weight(1, NumberOfDays),
                    weight(2, NumberOfDays),
                    weight(3, NumberOfDays),
                    weight(4, NumberOfDays),
                    weight(5, NumberOfDays),
                    weight(6, NumberOfDays)
                ]
            )
        )
        maintenance.adaptive.weightChange.previous = WeightSample(
            value: 95.06666667,
            source: .movingAverage,
            isDailyAverage: false,
            movingAverage: .init(
                interval: .init(1, .week),
                weights: [
                    weight(3, NumberOfDays),
                    weight(4, NumberOfDays),
                    weight(5, NumberOfDays),
                    weight(6, NumberOfDays),
                    weight(7, NumberOfDays),
                    weight(8, NumberOfDays),
                    weight(9, NumberOfDays)
                ]
            )
        )
        
        let testCase = HealthDetails(
            date: Date.now.moveDayBy(-NumberOfDays),
            maintenance: maintenance
        )

        
        let healthModel = HealthModel(
            delegate: TestHealthModelDelegate(),
            fetchCurrentHealthHandler: { testCase }
        )
        
        /// Sleep to let the fetch handler actually fetch the HealthDetails
        try await sleepTask(1.0, tolerance: 0.1)

        var currentWeights = healthModel.health.maintenance?.adaptive.weightChange.current.movingAverage?.weights ?? []
        var previousWeights = healthModel.health.maintenance?.adaptive.weightChange.previous.movingAverage?.weights ?? []

        XCTAssertEqual(currentWeights[0], weight(0, NumberOfDays))
        XCTAssertEqual(currentWeights[4], weight(4, NumberOfDays))
        XCTAssertEqual(previousWeights[3], weight(6, NumberOfDays))

        try await healthModel.refresh()

        currentWeights = healthModel.health.maintenance?.adaptive.weightChange.current.movingAverage?.weights ?? []
        previousWeights = healthModel.health.maintenance?.adaptive.weightChange.previous.movingAverage?.weights ?? []

        XCTAssertEqual(currentWeights[0 + NumberOfDays], weight(0, NumberOfDays))
        XCTAssertEqual(previousWeights[0], weight(0, NumberOfDays))
        XCTAssertEqual(previousWeights[3], weight(3, NumberOfDays))
    }
    
    func testRefresh_Maintenance_3_Days_Overlap_HealthKit() async throws {

        let NumberOfDays = 3

        let currentWeight = HealthDetails.Weight(
            source: .healthKit,
            isDailyAverage: true,
            healthKitQuantities: [
                .init(value: 92.12, date: Date(fromTimeString: "2023_12_14-09_24")!),
                .init(value: 93.5, date: Date(fromTimeString: "2023_12_14-12_24")!)
            ],
            valueInKg: 92.81
        )
        
        var maintenance = HealthDetails.Maintenance()
        maintenance.adaptive.interval = .init(3, .day)
        maintenance.adaptive.weightChange.current = WeightSample(
            value: currentWeight.valueInKg,
            source: currentWeight.source == .healthKit ? .healthKit : .userEntered,
            isDailyAverage: currentWeight.isDailyAverage,
            healthKitQuantities: currentWeight.healthKitQuantities,
            movingAverage: nil
        )
        maintenance.adaptive.weightChange.previous = WeightSample(
            value: 95.06666667,
            source: .movingAverage,
            isDailyAverage: false,
            movingAverage: .init(
                interval: .init(1, .week),
                weights: [
                    weight(3, NumberOfDays),
                    weight(4, NumberOfDays),
                    weight(5, NumberOfDays),
                    weight(6, NumberOfDays),
                    weight(7, NumberOfDays),
                    weight(8, NumberOfDays),
                    weight(9, NumberOfDays)
                ]
            )
        )
        
        let testCase = HealthDetails(
            date: Date.now.moveDayBy(-NumberOfDays),
            maintenance: maintenance
        )

        
        let healthModel = HealthModel(
            delegate: TestHealthModelDelegate(),
            fetchCurrentHealthHandler: { testCase }
        )
        
        /// Sleep to let the fetch handler actually fetch the HealthDetails
        try await sleepTask(1.0, tolerance: 0.1)

        var previousWeights = healthModel.health.maintenance?.adaptive.weightChange.previous.movingAverage?.weights ?? []

        XCTAssertEqual(previousWeights[3], weight(6, NumberOfDays))

        try await healthModel.refresh()

        previousWeights = healthModel.health.maintenance?.adaptive.weightChange.previous.movingAverage?.weights ?? []

        XCTAssertEqual(previousWeights[0], currentWeight)
        XCTAssertEqual(previousWeights[1], Empty)
        XCTAssertEqual(previousWeights[2], Empty)
    }
}

struct TestHealthModelDelegate: HealthModelDelegate {
    func saveHealth(_ healthDetails: HealthDetails, isCurrent: Bool) async throws {
    }
    
    func maintenanceBackendValues(for dateRange: ClosedRange<Date>) async throws -> MaintenanceValues {
        .init(values: [:])
    }
    
    func weights(for dateRange: ClosedRange<Date>) async throws -> [Date : HealthQuantity] {
        [:]
    }
    
    func updateBackendWithWeight(
        _ healthQuantity: HealthQuantity?,
        for date: Date
    ) async throws {
    }
    
    func planIsWeightDependent(on date: Date) async throws -> Bool {
        false
    }
    
    func dietaryEnergyInKcal(on date: Date) async throws -> Double? {
        nil
    }
}

func date(_ numberOfDaysBeforeToday: Int, _ timeString: String, _ NumberOfDays: Int) -> Date {
    let date = Date.now.moveDayBy(-NumberOfDays-numberOfDaysBeforeToday)
    let dateString = date.dateString
    return Date(fromTimeString: "\(dateString)-\(timeString)")!
}

func weight(_ days: Int, _ NumberOfDays: Int) -> HealthDetails.Weight {
    HealthDetails.Weight(
        source: .healthKit,
        isDailyAverage: true,
        healthKitQuantities: [
            .init(value: 90.5, date: date(days, "09_42", NumberOfDays)),
            .init(value: 91.8, date: date(days, "12_05", NumberOfDays)),
        ],
        valueInKg: 91.15
    )
}

let Empty = HealthDetails.Weight(
    source: .healthKit,
    isDailyAverage: true,
    healthKitQuantities: nil,
    valueInKg: nil
)
