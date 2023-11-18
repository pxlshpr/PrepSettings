import Foundation

public struct DaySample: Hashable, Codable {
    let value: Double
    
    /// If this is a moving average, these are the values that were averaged out where the Integer key is the number of days prior to the date this value is averaged for
    let movingAverageValues: [Int: Double]?
}

