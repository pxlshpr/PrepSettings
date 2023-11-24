import Foundation
import PrepShared

public struct WeightChange: Hashable, Codable {
    public var current: MaintenanceWeightSample
    public var previous: MaintenanceWeightSample
    
    public init() {
        self.current = MaintenanceWeightSample()
        self.previous = MaintenanceWeightSample()
    }    
}

public extension WeightChange {
    var delta: Double? {
        guard 
            let currentValue = current.value,
            let previousValue = previous.value
        else { return nil }
        return currentValue - previousValue
    }
    
    var deltaEquivalentEnergyInKcal: Double? {
        guard let delta else { return nil }
//        454 g : 3500 kcal
//        delta : x kcal
        return (3500 * delta) / BodyMassUnit.lb.convert(1, to: .kg)
    }
    
    var isEmpty: Bool {
        current.value == nil || previous.value == nil
    }
}

extension WeightChange {
    mutating func setValues(
        _ values: MaintenanceValues,
        _ date: Date,
        _ maintenanceInterval: HealthInterval
    ) {
        
        let previousDate = maintenanceInterval.startDate(with: date)

        func movingAverageWeightSample(on date: Date, interval: HealthInterval) -> MaintenanceWeightSample {
            var movingAverageValues: [Int: Double] = [:]
            for i in 0..<interval.numberOfDays {
                let movedDate = date.moveDayBy(-i)
                if let value = values.weightInKg(on: movedDate) {
                    movingAverageValues[i] = value
                }
            }
            let value = Array(movingAverageValues.values).averageValue
            return MaintenanceWeightSample(
                movingAverageInterval: interval,
                movingAverageValues: movingAverageValues,
                value: value
            )
        }
        
        func weightSample(on date: Date) -> MaintenanceWeightSample {
            MaintenanceWeightSample(
                movingAverageInterval: nil,
                movingAverageValues: nil,
                value: values.weightInKg(on: date)
            )
        }
        
        self.current = if let interval = current.movingAverageInterval {
            movingAverageWeightSample(on: date, interval: interval)
        } else {
            weightSample(on: date)
        }
        
        self.previous = if let interval = previous.movingAverageInterval {
            movingAverageWeightSample(on: previousDate, interval: interval)
        } else {
            weightSample(on: previousDate)
        }
    }
}
