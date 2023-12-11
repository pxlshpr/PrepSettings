import Foundation

public protocol HealthModelDelegate {
    func saveHealth(_ health: Health, isCurrent: Bool) async throws
    
    /**
     Takes in a date range and provides a dict of the dates as keys with the weight and dietary energy (both optional) for that day as values.
     
     – The date range provided will be the start of the previous weight sample’s moving average interval, leading up to the date of the Health struct that the maintenance is being calculated for
     – This function in Prep would simply query the backend for the DayEntities in that range and extract the values and supply the data required
     */
    func maintenanceBackendValues(for dateRange: ClosedRange<Date>) async throws -> MaintenanceValues

    func weights(for dateRange: ClosedRange<Date>) async throws -> [Date: HealthQuantity]

    /**
     Takes in a weight value, a type (HealthKit or userEntered) and a date and updates it in the backend.
     
     We do this:
     1. During the initial toggle of adaptive maintenance, when we fetch any HealthKit values that we don’t have weights for (in the backend), and update the backend with those (they will be set as HealthKit types)—in this case Prep will be creating the Day and/or Health and/or Weight if required and inserting that weight that didn't exist
     2. When the user manually changes a weight in the WeightSampleForm and confirms that they want to save it—in this case Prep would be updating the value that exists, and possibly recalculating the plan if it was dependent on it in any way
     */
    func updateBackendWeight(
        for date: Date,
        with healthQuantity: HealthQuantity?
//        with quantity: Quantity?,
//        source: HealthSource
    ) async throws
    
    /**
     Takes in a date and returns whether changes to the weight would affect its plan and therefore require user confirmation.
     
     This will be used when entering WeightSampleForm, so that we know whether to show a confirmation saying “Changing the weight for this day will also affect goals set on that day that depend on it. Are you sure?"
     */
    func planIsWeightDependent(on date: Date) async throws -> Bool

    /**
     Takes in a specific day and fetches the dietary energy for it.
     
     This will be used when a user toggles back on the backend value for dietary energy sample, so that we can fetch the most current value (if available)
     */
    func dietaryEnergyInKcal(on date: Date) async throws -> Double?
}
