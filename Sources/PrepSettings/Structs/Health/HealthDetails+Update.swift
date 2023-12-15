import Foundation

extension HealthDetails {
    
    mutating func update(with weightQuantity: HealthQuantity?, for date: Date) {
        
        /// If the provided `date` matches the internal one, set `weightQuantity` as `weight` (setting it to nil if need be)
        let isSameDate = date.startOfDay == self.date.startOfDay
        
        /// Otherwise, if this a healthKit sourced weight, check if `HealthDetails.weight` uses healthKit and this is a more recent quantity for it
        let isHealthKit = weight?.source == .healthKit && weightQuantity?.source == .healthKit
        let isRelevant = date.startOfDay <= self.date.startOfDay /// date is on or before this date
        let isMoreRecent = if let existingDate = weight?.quantity?.date {
            date.startOfDay >= existingDate.startOfDay
        } else {
            true
        } /// date is after the current date, if any
        let isMoreRecentHealthKitDate = isHealthKit && isRelevant && isMoreRecent

        let shouldReplaceWeight = isSameDate || isMoreRecentHealthKitDate
        if shouldReplaceWeight {
            self.weight = weightQuantity
        }

        /// [ ] Now update anything dependent on the weight by recalculating
        recalculate()
        
        /// [ ] Send a notification for any related HealthModel's to update themselves if they have this struct (matched by the date) or use the weight for this day in either of their samples or as one fo the average components
        
    }
}
