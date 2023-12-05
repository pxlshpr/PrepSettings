import SwiftUI
import PrepShared

extension WeightSampleForm {
    @Observable class Model {

        let initialSample: WeightSample
        var sample: WeightSample

        let date: Date
        var displayedValue: Double?
        var isRemoved: Bool

        let healthModel: HealthModel
        
        init(sample: WeightSample, date: Date, healthModel: HealthModel) {
            self.initialSample = sample
            self.isRemoved = sample.value == nil
            self.sample = sample
            self.date = date
            self.healthModel = healthModel
            
            if let value = sample.value {
                self.displayedValue = BodyMassUnit.kg.convert(value, to: SettingsStore.shared.bodyMassUnit)
            } else {
                self.displayedValue = nil
            }
        }
    }
}

extension WeightSampleForm.Model {
    
    func value(in unit: BodyMassUnit) -> Double? {
        guard let value = sample.value else { return nil }
        return BodyMassUnit.kg.convert(value, to: unit)
    }
    
    var isNotDirty: Bool {
        sample == initialSample
    }
    
    var isSaveDisabled: Bool {
        /// If the sample matches the initialSample, disable
        if isNotDirty { return true }

        /// If we're using moving average but don't have a value (due to there not being any values entered), disable
        if isUsingMovingAverage, sample.value == nil { return true }

        /// If we've come to this point where value is nil, we're not using a moving average, and the form is dirty—enable
        guard let value = sample.value else { return false }

        /// Finally, if the value is not greater than 0, disable
        return value <= 0
    }

    func bodyMassUnitChanged(old: BodyMassUnit, new: BodyMassUnit) {
        if isUsingMovingAverage {
            guard let value = self.value(in: new) else { return }
            withAnimation {
                displayedValue = value
            }
        } else {
            /// Otherwise, if user is manually entering value—don't change it, but convert the `valueInKg` value stored internally to reflect the new unit
            guard let displayedValue else { return }
            let converted = new.convert(displayedValue, to: .kg)
            self.sample.value = converted
        }
//        if !isUsingMovingAverage {
//            sampleSampleValueAsDisplayedValueConvertedToKg()
//        }
//        guard let value = sample.value else { return }
//        let converted = BodyMassUnit.kg.convert(value, to: new)
//        sample.value = converted
//
//        withAnimation {
//            if let movingAverageValues = sample.movingAverageValues {
//                for (i, value) in movingAverageValues {
//                    let converted = old.convert(value, to: new)
//                    sample.movingAverageValues?[i] = converted
//                }
//            }
//        }
    }
    
//    var weightStonesComponent: Int {
//        get { Int(displayedValue.whole) }
//        set {
//            let value = Double(newValue) + (weightPoundsComponent / PoundsPerStone)
////            self.value = value
//            displayedValue = value
//        }
//    }
//    
//    var weightPoundsComponent: Double {
//        get { displayedValue.fraction * PoundsPerStone }
//        set {
//            let newValue = min(newValue, PoundsPerStone-1)
//            let value = Double(weightStonesComponent) + (newValue / PoundsPerStone)
////            self.value = value
//            displayedValue = value
//        }
//    }
}

extension WeightSampleForm.Model {
    
    func saveWeight(_ weight: Double?, for date: Date) {
        let index = -date.numberOfDaysFrom(self.date)
        withAnimation {
            sample.movingAverageValues?[index] = weight
            calculateAverage()
        }
    }
    
    func calculateAverage() {
        guard let values = sample.movingAverageValues, !values.isEmpty else {
            sample.value = nil
            return
        }
        let averageInKg = (values.reduce(0) { $0 + $1.value }) / Double(values.count)
        sample.value = averageInKg
        displayedValue = BodyMassUnit.kg.convert(averageInKg, to: SettingsStore.shared.bodyMassUnit)
    }
    
    var movingAverageNumberOfDays: Int {
        sample.movingAverageInterval?.numberOfDays ?? DefaultNumberOfDaysForMovingAverage
    }
    
    func setMovingAverageValues(_ values: [Int: Double]) {
        sample.movingAverageValues = values
        calculateAverage()
    }
    
    var movingAverageIntervalPeriodBinding: Binding<HealthPeriod> {
        Binding<HealthPeriod>(
            get: { self.movingAverageIntervalPeriod },
            set: { newValue in
                withAnimation {
                    var value = self.movingAverageIntervalValue
                    switch newValue {
                    case .day:
                        value = max(2, value)
                    default:
                        break
                    }
                    self.sample.movingAverageInterval = .init(value, newValue)
                }
                self.setWeightsFromBackend()
            }
        )
    }
    
    var movingAverageIntervalPeriod: HealthPeriod {
        sample.movingAverageInterval?.period ?? .week
    }
    
    var intervalValueBinding: Binding<Int> {
        Binding<Int>(
            get: { self.movingAverageIntervalValue },
            set: { newValue in
                //TODO: Fetch values here for new range
                let interval = HealthInterval(newValue, self.movingAverageIntervalPeriod)
                withAnimation {
                    self.sample.movingAverageInterval = interval
                }
                self.setWeightsFromBackend()
            }
        )
    }
    
    var isUsingMovingAverageBinding: Binding<Bool> {
        Binding<Bool>(
            get: { self.isUsingMovingAverage },
            set: { newValue in
                switch newValue {
                case false:
                    /// When turning the calculated moving average off—round the value to 1 decimal place in case we had a more precise value stored
                    self.displayedValue = self.displayedValue?.rounded(toPlaces: 1)
                    withAnimation {
                        self.sample.movingAverageValues = nil
                    }
                case true:
                    self.setWeightsFromBackend()
                }
            }
        )
    }
    
    func setWeightsFromBackend() {
        Task {
            let backendValues = try await self.backendValuesForMovingAverage()
            let values: [Int: Double] = if !backendValues.isEmpty {
                backendValues
            } else if let value = self.sample.value, value > 0 {
                /// If the user has entered a weight already, set that as the first weight
                [0: value]
            } else {
                [:]
            }
            await MainActor.run {
                withAnimation {
                    self.setMovingAverageValues(values)
                }
            }
        }
    }
    
    func backendValuesForMovingAverage() async throws -> [Int: Double] {
        let interval = sample.movingAverageInterval ?? DefaultWeightMovingAverageInterval
        return try await healthModel.weightValuesForMovingAverage(
            interval: interval,
            date: date
        )
    }

    var isUsingMovingAverage: Bool {
        sample.movingAverageValues != nil
    }
    
    var movingAverageIntervalValue: Int {
        sample.movingAverageInterval?.value ?? 1
    }
}

extension HealthModel {
    var intervalValueBinding: Binding<Int> {
        Binding<Int>(
            get: { self.intervalValue },
            set: { newValue in
                withAnimation {
                    self.health.maintenance?.adaptive.interval = .init(newValue, self.intervalPeriod)
                }
                Task {
                    try await self.calculateAdaptiveMaintenance()
                }
            }
        )
    }
    
    var intervalPeriodBinding: Binding<HealthPeriod> {
        Binding<HealthPeriod>(
            get: { self.intervalPeriod },
            set: { newValue in
                withAnimation {
                    var value = self.intervalValue
                    switch newValue {
                    case .day:
                        value = max(2, value)
                    default:
                        break
                    }
                    self.health.maintenance?.adaptive.interval = .init(value, newValue)
                }
                Task {
                    try await self.calculateAdaptiveMaintenance()
                }
            }
        )
    }
    
    var maintenance: Health.Maintenance {
        health.maintenance ?? .init()
    }
    
    var hasCalculatedMaintenance: Bool {
        health.hasCalculatedMaintenance
    }
    
    var hasEstimatedMaintenance: Bool {
        health.hasEstimatedMaintenance
    }
    
    var hasMaintenanceValue: Bool {
        health.hasMaintenanceValue
    }
    
    var intervalPeriod: HealthPeriod {
        maintenance.adaptive.interval.period
    }

    var intervalValue: Int {
        maintenance.adaptive.interval.value
    }
}
