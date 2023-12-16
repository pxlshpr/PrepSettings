import Foundation
import PrepShared

public struct WeightSample: Hashable, Codable {
    var value: Double?
    
    var source: WeightSampleSource
    var isDailyAverage: Bool

    var healthKitQuantities: [Quantity]?

    var movingAverage: MovingAverage?

    public struct MovingAverage: Hashable, Codable {
        public var interval: HealthInterval
        public var weights: [HealthDetails.Weight]
        
        public init(
            interval: HealthInterval = DefaultWeightMovingAverageInterval,
            weights: [HealthDetails.Weight] = DefaultMovingAverageWeights
        ) {
            self.interval = interval
            self.weights = weights
        }
    }
    
    public init(
        value: Double? = nil,
        source: WeightSampleSource = .movingAverage,
        isDailyAverage: Bool = false,
        healthKitQuantities: [Quantity]? = nil,
        movingAverage: MovingAverage? = .init()
    ) {
        self.value = value
        self.source = source
        self.isDailyAverage = isDailyAverage
        self.healthKitQuantities = healthKitQuantities
        self.movingAverage = movingAverage
    }

    public mutating func modifyForNewDay(
        from date: Date,
        laterSample: WeightSample? = nil,
        interval: HealthInterval? = nil
    ) {
        switch source {
        case .userEntered:
            /// Clear the value as it does not apply to the new day
            value = nil
        case .movingAverage:
            guard let intervalDays = movingAverage?.interval.numberOfDays else { break }

            /// Determine how much to shift the moving average array by getting the number of days since `date` (up to a maximum of the number of days in the interval)
            let numberOfDays = Date.now.numberOfDaysFrom(date)
            let shiftCount = min(intervalDays, numberOfDays)

            /// Insert that many new weights at start of array with source set as `.healthKit`
            var newWeights = Array(
                repeating: HealthDetails.Weight(source: .healthKit, isDailyAverage: true),
                count: shiftCount
            )
            
            if let laterSample, let adaptiveInterval = interval {
                
                switch laterSample.source {
                case .movingAverage:
                    if let laterMovingAverage = laterSample.movingAverage {
                        /// If we've got a sample that's interval later, copy across any overlapping values with the date change
                        for newIndex in 0..<shiftCount {
                            let i = adaptiveInterval.numberOfDays - (numberOfDays - newIndex)
                            guard i >= 0, i < laterMovingAverage.weights.count else { continue }
                            let weight = laterMovingAverage.weights[i]
                            newWeights[newIndex] = weight
                        }
                    }
                case .healthKit, .userEntered:
                    //TODO: Test this
                    for newIndex in 0..<shiftCount {
                        let i = adaptiveInterval.numberOfDays - (shiftCount - newIndex)
                        guard i < 1 else { continue }
                        let weight = HealthDetails.Weight(
                            source: laterSample.source == .healthKit ? .healthKit : .userEntered,
                            isDailyAverage: laterSample.isDailyAverage,
                            healthKitQuantities: laterSample.healthKitQuantities,
                            valueInKg: laterSample.value
                        )
                        newWeights[newIndex] = weight
                    }
                }
            }
            
            movingAverage?.weights.insert(contentsOf: newWeights, at: 0)
            
            /// Remove that many weights from the end of the array to maintain the number of days of the moving average interval
            movingAverage?.weights.removeLast(shiftCount)
            
        case .healthKit:
            break
        }
    }
}

extension WeightSample {
    func value(in unit: BodyMassUnit) -> Double? {
        guard let value else { return nil }
        return BodyMassUnit.kg.convert(value, to: unit)
    }
    
//    mutating func fill(using request: HealthKitQuantityRequest) async throws {
//        if let sample = try await request.daySample(movingAverageInterval: self.movingAverageInterval)
//        {
//            movingAverageValues = sample.movingAverageValues
//            value = sample.value
//        } else {
//            movingAverageValues = nil
//            value = nil
//        }
//    }
}
