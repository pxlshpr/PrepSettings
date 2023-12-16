import Foundation
import PrepShared

public struct WeightSample: Hashable, Codable {
    var value: Double?
    
    var source: WeightSampleSource
    var isDailyAverage: Bool
    
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
        movingAverage: MovingAverage? = .init()
    ) {
        self.value = value
        self.source = source
        self.isDailyAverage = isDailyAverage
        self.movingAverage = movingAverage
    }
    
    public mutating func modifyForNewDay(from date: Date) {
        switch source {
        case .userEntered:
            /// Clear the value as it does not apply to the new day
            value = nil
        case .movingAverage:
            guard let intervalDays = movingAverage?.interval.numberOfDays else { break }

            /// Determine how much to shift the moving average array by getting the number of days since `date` (up to a maximum of the number of days in the interval)
            let shiftCount = min(intervalDays, Date.now.numberOfDaysFrom(date))

            /// Insert that many new weights at start of array with source set as `.healthKit`
            let newWeights = Array(
                repeating: HealthDetails.Weight(source: .healthKit, isDailyAverage: true), 
                count: shiftCount
            )
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
