import SwiftUI
import PrepShared

/// [ ] Design the Energy Expenditure cell for when we don't have enough weight data
/// [ ] Consider having another tag below the one for Calculated/Estimated and have it say the message, e.g. "Insufficient weight data" or "Insufficient food data"
/// [ ] If user taps this tag, pop up a small message elaborating (e.g. "You need to have at least [2 weight measurements/1 day with food logged] over the [past two weeks/two weeks prior] to calculate your expenditure."

public struct MaintenanceForm: View {
    
    @Environment(SettingsStore.self) var settingsStore: SettingsStore

    @Bindable var model: HealthModel

    public init(_ model: HealthModel) {
        self.model = model
    }

    public var body: some View {
        Form {
            MaintenanceFormSections(model)
                .environment(settingsStore)
        }
        .navigationTitle("Maintenance Energy")
        .scrollDismissesKeyboard(.interactively)
    }
}

/**
 Energy burn algorithm:
 
 getWeightMovingAverage(from date: Date, in unit: WeightUnit = .kg) -> Double?
 1. Fetch all weights for the past week from the date provided (including it)
     - Fetch from our backend, getting HealthDetails for each Day
     - Fail if we have 0 entires
 2. For each day, calculate average daily weight (average out any values on that day)
 3. Now get the moving average for the weight by averaging out the daily values

 getTotalConsumedCalories(from date: Date, in unit: EnergyUnit = .kcal) -> Double?
 1. Fetch consumed calories over the past week from the date provided (not including it)
     - Fetch from our backend, getting the energyInKcals for each Day
     - Fail if we have 0 entires
 2. If we have less than 7 values, get the average and use this for the missing days
 3. Sum all the day's values

 calculateEnergyBurn(for date: Date, in unit: EnergyUnit = .kcal) -> Result<Double, EnergyBurnError>
 1. weightDelta = getWeightMovingAverage(from: date) - getWeightMovingAverage(from: date-7days)
 2. Convert to pounds, then convert to weightDeltaInCalories using 1lb = 3500 kcal
 3. calories = getTotalConsumedCalories(from: date)
 4. Now burn = calories - weightDelta
 5. If we had an error, it would have been weightDelta or calories not being calculable because of not having at least 1 entry in the window

 */
