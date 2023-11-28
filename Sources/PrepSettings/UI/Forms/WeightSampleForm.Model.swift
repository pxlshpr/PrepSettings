import SwiftUI
import PrepShared

extension WeightSampleForm {
    @Observable class Model {

        let initialSample: WeightSample
        var sample: WeightSample

        let date: Date
        var value: Double?
        var displayedValue: Double {
            didSet {
                value = displayedValue
                sample.value = displayedValue
            }
        }

        init(sample: WeightSample, date: Date) {
            self.initialSample = sample
            self.sample = sample
            self.value = sample.value
            self.displayedValue = sample.value ?? 0
            self.date = date
        }
    }
}

extension WeightSampleForm.Model {
    
    var isNotDirty: Bool {
        sample == initialSample
    }
    
    var isSaveDisabled: Bool {
        /// If the sample matches the initialSample, disable
        if isNotDirty { return true }

        /// If we're using moving average but don't have a value (due to there not being any values entered), disable
        if isUsingMovingAverage, value == nil { return true }

        /// If we've come to this point where value is nil, we're not using a moving average, and the form is dirty—enable
        guard let value else { return false }

        /// Finally, if the value is not greater than 0, disable
        return value <= 0
    }

    func bodyMassUnitChanged(old: BodyMassUnit, new: BodyMassUnit) {
        guard let value else { return }
        let converted = old.convert(value, to: new)
        self.value = converted
        displayedValue = converted
        
        withAnimation {
            if let movingAverageValues = sample.movingAverageValues {
                for (i, value) in movingAverageValues {
                    let converted = old.convert(value, to: new)
                    sample.movingAverageValues?[i] = converted
                }
            }
        }
    }
    
    var weightStonesComponent: Int {
        get { Int(displayedValue.whole) }
        set {
            let value = Double(newValue) + (weightPoundsComponent / PoundsPerStone)
            self.value = value
            displayedValue = value
        }
    }
    
    var weightPoundsComponent: Double {
        get { displayedValue.fraction * PoundsPerStone }
        set {
            let newValue = min(newValue, PoundsPerStone-1)
            let value = Double(weightStonesComponent) + (newValue / PoundsPerStone)
            self.value = value
            displayedValue = value
        }
    }
}

extension WeightSampleForm.Model {
    
    func saveWeight(_ weight: Double?, at index: Int) {
        withAnimation {
            sample.movingAverageValues?[index] = weight
            calculateAverage()
        }
    }
    
    func calculateAverage() {
        guard let values = sample.movingAverageValues, !values.isEmpty else {
            value = nil
            return
        }
        displayedValue = (values.reduce(0) { $0 + $1.value }) / Double(values.count)
    }
    
    var movingAverageNumberOfDays: Int {
        sample.movingAverageInterval?.numberOfDays ?? DefaultNumberOfDaysForMovingAverage
    }
    
    var usingMovingAverageBinding: Binding<Bool> {
        Binding<Bool>(
            get: { self.isUsingMovingAverage },
            set: { newValue in
                withAnimation {
                    switch newValue {
                    case false:
                        self.sample.movingAverageValues = nil
                    case true:
                        /// If the user has entered a weight already, set that as the first weight
                        if let value = self.value, value > 0 {
                            self.sample.movingAverageValues = [0: value]
                        } else {
                            self.sample.movingAverageValues = [:]
                        }
                        self.calculateAverage()
                    }
                }
            }
        )
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
            }
        )
    }
    
    var movingAverageIntervalPeriod: HealthPeriod {
        sample.movingAverageInterval?.period ?? .week
    }
    
    var movingAverageIntervalValueBinding: Binding<Int> {
        Binding<Int>(
            get: { self.movingAverageIntervalValue },
            set: { newValue in
//                guard let interval = self.sample.movingAverageInterval else { return }
                withAnimation {
                    self.sample.movingAverageInterval = .init(newValue, self.movingAverageIntervalPeriod)
                }
            }
        )
    }

    var movingAverageIntervalValue: Int {
        sample.movingAverageInterval?.value ?? 1
    }
    
    var isUsingMovingAverage: Bool {
        sample.movingAverageValues != nil
    }
    
    func movingAverageValue(at index: Int) -> Double? {
        sample.movingAverageValues?[index]
    }
}

extension HealthModel {
    var intervalValueBinding: Binding<Int> {
        Binding<Int>(
            get: { self.intervalValue },
            set: { newValue in
                withAnimation {
                    self.health.maintenanceEnergy?.interval = .init(newValue, self.intervalPeriod)
                }
                Task {
                    try await self.turnOnAdaptiveMaintenance()
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
                    self.health.maintenanceEnergy?.interval = .init(value, newValue)
                }
                Task {
                    try await self.turnOnAdaptiveMaintenance()
                }
            }
        )
    }
    
    var maintenance: Health.MaintenanceEnergy {
        health.maintenanceEnergy ?? .init()
    }
    
    var intervalPeriod: HealthPeriod {
        maintenance.interval.period
    }

    var intervalValue: Int {
        maintenance.interval.value
    }
}
