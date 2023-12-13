import Foundation

extension HealthDetails {
    
    mutating func update(with weightQuantity: HealthQuantity?, for date: Date) {
        
        /// First, update the weight if needed
        /// [x] If the provided `date` matches the internal one, set `weightQuantity` as `weight` (setting it to nil if need be)
        /// [ ] Otherwise, if the weight is uses healthKit and this weight pertains to it, update it
        let isSameDate = date.startOfDay == self.date.startOfDay
        
        
        let isHealthKit = weight?.source == .healthKit && weightQuantity?.source == .healthKit

        /// date is on or before this date
        let isRelevant = date.startOfDay <= self.date.startOfDay

        /// date is after the current date, if any
        let isMoreRecent = if let existingDate = weight?.quantity?.date {
            date.startOfDay >= existingDate.startOfDay
        } else {
            true
        }
        let isMoreRecentHealthKitDate = isHealthKit && isRelevant && isMoreRecent

        let shouldReplaceWeight = isSameDate || isMoreRecentHealthKitDate
        guard shouldReplaceWeight else  {
            return
        }

        self.weight = weightQuantity

        /// [ ] Now update anything dependent on the weight

        /// [ ] Send a notification for any related HealthModel's to update themselves if they have this struct
    }
}
