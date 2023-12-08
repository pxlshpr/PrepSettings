import SwiftUI
import PrepShared

extension WeightSections {
    @Observable class Model {
        
        let formType: WeightFormType
        let healthModel: HealthModel
        var date: Date
        var value: Double?

        var source: HealthSource?

        var sampleSource: WeightSampleSource?
        let initialSample: WeightSample?
        var sample: WeightSample?
        
        var healthKitQuantities: [Quantity]?
        var healthKitValueForDate: Double?
        
        var backendQuantities: [Date: HealthQuantity]?
        
        /// Health init
        init(
            healthModel: HealthModel
        ) {
            self.formType = .healthDetails
            self.healthModel = healthModel
            self.date = healthModel.health.date
            
            let weight = healthModel.health.weight
            self.value = weight?.quantity?.value
            self.source = weight?.source
            
            self.initialSample = nil
            self.sample = nil
        }
        
        /// Weight Sample init
        init(
            sample: WeightSample,
            date: Date,
            healthModel: HealthModel
        ) {
            self.formType = .adaptiveSample
            self.healthModel = healthModel
            self.date = date
            
            self.value = sample.value
            self.source = nil
//            self.sampleSource = sample.source
            self.sampleSource = .movingAverage
            
            self.initialSample = sample
            self.sample = sample
        }
        
        /// Average Component init
        init(
            value: Double?,
            date: Date,
            healthModel: HealthModel
        ) {
            self.formType = .adaptiveSample
            self.healthModel = healthModel
            self.date = date
            
            self.value = value
            self.source = .userEntered
            
            self.sampleSource = nil
            self.initialSample = nil
            self.sample = nil
        }

    }
}

public extension Array where Element == Quantity {
    func removingDuplicateQuantities() -> [Quantity] {
        var addedDict = [Quantity: Bool]()
        
        return filter {
            let rounded = $0.rounded(toPlaces: 2)
            return addedDict.updateValue(true, forKey: rounded) == nil
        }
    }
}

extension Quantity {
    func rounded(toPlaces places: Int) -> Quantity {
        Quantity(
            value: self.value.rounded(toPlaces: places),
            date: self.date
        )
    }
}
extension WeightSections.Model {
    
    func fetchBackendData() async throws {
        switch formType {
        case .adaptiveSample:
            /// Fetch the backend data for the maximum range for when we use "Moving Average"
            /// Get the maximum possible date range, that being `2 weeks` from date, backwards
            let range = date.moveDayBy(-14)...date
            let quantities = try await healthModel.delegate.weights(for: range)
            
            await MainActor.run {
                self.backendQuantities = quantities
            }
            
        default:
            break
        }
    }
    
    func fetchHealthKitData() async throws {
        guard !isPreview else {
            return
        }
        
        switch formType {
        case .healthDetails:
            /// [ ] Fetch the latest day's values from HealthKit
            /// [ ] Keep this stored in the model
            /// [ ] If this value exists (ie is stored), only then show the Apple Health option in source
            let quantities = try await HealthStore.latestDaysWeights(in: .kg, for: date)?
                .removingDuplicateQuantities()
            
            await MainActor.run {
                self.healthKitQuantities = quantities
                if source == .healthKit {
                    setHealthKitQuantity()
                }
            }

        case .adaptiveSample:
            /// [ ] Fetch the date's values, along with the values for all dates within the moving average interval (if sourceType is moving average)
            /// [ ] Keep them stored in the model
            /// [ ] If the value for the date exists, only then show the Apple Health option

            let quantities = try await HealthStore.daysWeights(in: .kg, for: date)?
                .removingDuplicateQuantities()
            
            print("We here")
            
            await MainActor.run {
                self.healthKitQuantities = quantities
                if source == .healthKit {
                    setHealthKitQuantity()
                }
            }

        case .adaptiveSampleAverageComponent:
            /// [ ] Fetch the date's value
            /// [ ] Keep this stored in the model
            /// [ ] If this value exists (ie is stored), only then show the Apple Health option
            break
        }
    }
    
    func setHealthKitQuantity() {
        let value: Double? = switch useDailyAverage {
        case true:
            /// Set daily average
            healthKitQuantities?.averageValue
        case false:
            healthKitQuantities?.last?.value
        }
        
        let date = healthKitLatestQuantity?.date
        
        let quantity: Quantity?
        if let value {
            quantity = Quantity(value: value, date: date)
        } else {
            quantity = nil
        }
        
        withAnimation {
            switch formType {
            case .healthDetails:
                healthModel.health.weight?.quantity = quantity
            case .adaptiveSample:
                sample?.value = quantity?.value
            case .adaptiveSampleAverageComponent:
                self.value = quantity?.value
            }
        }
    }
    
    func setWeight() {
        switch formType {
        case .healthDetails:
            healthModel.add(.weight)
        default:
            break
        }
    }

    func removeWeight() {
        switch formType {
        case .healthDetails:
            healthModel.remove(.weight)
        default:
            break
        }
    }
}

extension WeightSections.Model {
    
    var isUserEntered: Bool {
        switch formType {
        case .adaptiveSample:   sampleSource == .userEntered
        default:                source == .userEntered
        }
    }
    var footerString: String? {
        switch formType {
        case .healthDetails:
            HealthType.weight.reason!
        default:
            nil
        }
    }
    
    var isRemoved: Bool {
        switch formType {
        case .healthDetails:
            healthModel.health.weight == nil
        case .adaptiveSample:
            false
        case .adaptiveSampleAverageComponent:
            false
        }
    }
    
    var healthKitLatestQuantity: Quantity? {
        healthKitQuantities?.last
    }
    
    func computedValue(in unit: BodyMassUnit) -> Double? {
        switch formType {
        case .healthDetails:
            switch source {
            case .healthKit:
                guard let value = healthModel.health.weight?.quantity?.value else { return nil }
                return BodyMassUnit.kg.convert(value, to: unit)
            default:
                return nil
            }
            
        case .adaptiveSample:
            switch sampleSource {
            case .healthKit:
                guard let value = healthKitValueForDate else { return nil }
                return BodyMassUnit.kg.convert(value, to: unit)
            case .movingAverage:
                return 69.0
            default:
                return nil
            }
            
        case .adaptiveSampleAverageComponent:
            switch source {
            case .healthKit:
                guard let value = healthKitValueForDate else { return nil }
                return BodyMassUnit.kg.convert(value, to: unit)
            default:
                return nil
            }
        }
    }
    
    var quantity: Quantity? {
        guard let value else { return nil }
        return .init(value: value, date: date)
    }
}

extension WeightSections.Model {
    
    var shouldShowDailyAverageSection: Bool {
        switch formType {
        case .healthDetails, .adaptiveSampleAverageComponent:
            source == .healthKit
        case .adaptiveSample:
            sampleSource == .healthKit
        }
    }
    
    var shouldShowDailyAverageValuesSection: Bool {
        switch formType {
        case .healthDetails:
            source == .healthKit
            && useDailyAverage
        case .adaptiveSampleAverageComponent:
            false
        case .adaptiveSample:
            sampleSource == .healthKit
            && useDailyAverage
        }
    }
    
    var shouldShowDate: Bool {
        switch formType {
        case .healthDetails:
            source == .healthKit
        default:
            false
        }
    }
}

extension WeightSections.Model {
    
    var sourceBinding: Binding<HealthSource> {
        Binding<HealthSource>(
            get: { self.source ?? .userEntered },
            set: { newValue in
                withAnimation {
                    self.source = newValue
                }
                
                switch self.formType {
                case .healthDetails:
                    /// [ ] Directly set the source instead of using the binding
                    /// [ ] If we switch to HealthKit, simply use the value that we would have fetched (this option shouldn't be available otherwise)
                    /// [ ] We might have to stop syncing weight from healthKit whenever biometrics change since we're doing it in the form
//                    self.healthModel.weightSource = newValue
                    self.healthModel.health.weight?.source = newValue
                    switch newValue {
                    case .healthKit:
                        self.setHealthKitQuantity()
                    case .userEntered:
                        break
                    }
                case .adaptiveSampleAverageComponent:
                    /// [ ] We can only set to HealthKit if there is a value available—and if we do this, change the Health details for that date only
                    /// [ ] If we switch to custom, change the average component and also the health details weight by updating the 'backend weight
                    Task {
                        if let quantity = self.quantity {
                            try await self.healthModel.delegate.updateBackendWeight(
                                for: self.date,
                                with: quantity,
                                source: newValue
                            )
                        }
                    }
                case .adaptiveSample:
                    /// Not handled here (we use `sampleBinding` instead
                    break
                }
            }
        )
    }
    
    var sampleSourceBinding: Binding<WeightSampleSource> {
        Binding<WeightSampleSource>(
            get: { self.sampleSource ?? .userEntered },
            set: { newValue in
                /// [ ] If we switch to `.movingAverage` – fetch the values for the dates from the backend (whatever value we have stored for each date)
                /// [x] If we switch to `.healthKit` – use the values we would have fetched depending on if we're using average day's entires or not
                
                withAnimation {
                    self.sampleSource = newValue
                }
                
                switch newValue {
                case .healthKit:
                    self.setHealthKitQuantity()
                case .movingAverage:
                    self.setMovingAverageValue()
                default:
                    break
                }
                
                /// [ ]  Change source for the day this pertains to
                Task {
//                    if let quantity = self.quantity {
//                        try await self.healthModel.delegate.updateBackendWeight(
//                            for: self.date,
//                            with: quantity,
//                            source: newValue
//                        )
//                    }
                }
            }
        )
    }
    
    func setMovingAverageValue() {
        guard let values = sample?.movingAverageValues,
              let average = Array(values.values).averageValue
        else {
            self.sample?.value = nil
            return
        }
        self.sample?.value = average
    }
    
    var useDailyAverage: Bool {
        get {
            switch formType {
            case .healthDetails:
                healthModel.health.weight?.isDailyAverage ?? false
            case .adaptiveSampleAverageComponent:
                false
            case .adaptiveSample:
                sample?.isDailyAverage == true
            }
        }
        set {
            switch formType {
            case .healthDetails:
                withAnimation {
                    healthModel.health.weight?.isDailyAverage = newValue
                }
                setHealthKitQuantity()
            case .adaptiveSampleAverageComponent:
                break
            case .adaptiveSample:
                withAnimation {
                    sample?.isDailyAverage = newValue
                }
                setHealthKitQuantity()
            }
        }
    }
    
    var movingAverageIntervalPeriod: HealthPeriod {
        get { sample?.movingAverageInterval?.period ?? .default }
        set {
            guard let sample else { return }
            var interval = sample.movingAverageInterval ?? .default
            interval.period = newValue
            withAnimation {
                self.sample?.movingAverageInterval = interval
                self.sample?.movingAverageInterval?.correctIfNeeded()
            }
            /// [ ] Once changed – fetch new weights
//            Task {
//            }
        }
    }

    var movingAverageIntervalValue: Int {
        get { sample?.movingAverageInterval?.value ?? 1 }
        set {
            guard let sample else { return }
            guard newValue >= movingAverageIntervalPeriod.minValue,
                  newValue <= movingAverageIntervalPeriod.maxValue
            else { return }
            
            /// [ ] Once changed – fetch new weights
            var interval = sample.movingAverageInterval ?? .default
            interval.value = newValue
            withAnimation {
                self.sample?.movingAverageInterval = interval
            }
//            Task {
//            }
        }
    }
    
    var movingAverageNumberOfDays: Int {
        sample?.movingAverageInterval?.numberOfDays ?? DefaultNumberOfDaysForMovingAverage
    }
    
//    func movingAverageValue(at index: Int) -> Double? {
//        guard let value = sample?.movingAverageValues?[index]
//        else { return nil }
//        return BodyMassUnit.kg.convert(value, to: SettingsStore.bodyMassUnit)
//    }
    
    func movingAverageValue(at index: Int) -> Double? {
        let date = self.date.moveDayBy(-index)
        guard let value = backendQuantities?[date]?.quantity?.value
        else { return nil }
        return BodyMassUnit.kg.convert(value, to: SettingsStore.bodyMassUnit)

//        guard let value = sample?.movingAverageValues?[index]
//        else { return nil }
//        return BodyMassUnit.kg.convert(value, to: SettingsStore.bodyMassUnit)
    }
}
