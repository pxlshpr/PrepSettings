import SwiftUI
import PrepShared

/// [ ] Consider having different units, by first renaming `value` to `valueInKg`, then addressing every place we use it
/// [ ] Also consider different units for the two other form types

extension WeightForm {
    @Observable class Model {
        
        let formType: WeightFormType
        let healthModel: HealthModel
        var date: Date

        /// Used for `.healthDetails` and `.specificDate`
        var source: HealthSource?

        /// Used for `.specificDate`
        var value: Double?
        var isDailyAverage: Bool?

        /// Used for `.adaptiveSample`
        var sample: WeightSample?
        var sampleSource: WeightSampleSource?

        var healthKitQuantities: [Quantity]?
        var healthKitValueForDate: Double?
        
        /// Reference values kept so that when changing interval we're able to display values quickly without re-querying for them
        var backendQuantities: [Date: HealthQuantity]?
        
        /// List of moving average weights that are displayed based on the current interval
        var movingAverageDatedWeights: [DatedWeight] = []
        
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
        }
        
        /// Weight Sample init
        init(
            sample: WeightSample,
            date: Date,
            isPrevious: Bool,
            healthModel: HealthModel
        ) {
            self.formType = .adaptiveSample(isPrevious: isPrevious)
            self.healthModel = healthModel
            self.date = date
            
            self.value = sample.value
            self.sampleSource = sample.source
            
            self.sample = sample
            
            /// Initialize movingAverageDatedWeights with empty placeholders
            if let dayCount = sample.movingAverageInterval?.numberOfDays {
                for i in 0..<dayCount {
                    let date = date.moveDayBy(-i)
                    self.movingAverageDatedWeights.append(.init(date: date))
                }
            }
        }
        
        /// Average Component init
        init(
            date: Date,
            value: Double?,
            source: HealthSource?,
            isDailyAverage: Bool?,
            healthModel: HealthModel
        ) {
            self.formType = .specificDate
            self.healthModel = healthModel
            self.date = date
            
            self.value = value
            self.source = source ?? .userEntered
            self.isDailyAverage = isDailyAverage
        }

    }
}

extension WeightForm.Model {
    func didUpdateWeight(notification: Notification) {
        
        /// We're only interested in external weight changes if we're the adaptive weight form using a moving average
        guard formType.isAdaptiveSample, sampleSource == .movingAverage else {
            return
        }
        
        /// Make sure we have the date, the actual weight data, and the array of healthKit quantities
        guard let date = notification.date,
              let healthQuantity = notification.weightHealthQuantity
        else { return }
        
        /// [ ] Only continue if the date pertains to this form (guard that the date lies within the date range for the moving average interval)

        /// If the array of quantities isn't initialized yet, do so with this quantity
        guard backendQuantities != nil else {
            backendQuantities?[date] = healthQuantity
            return
        }
        
        /// If the quantity for this date already exists, replace it with this, otherwise simply set it
        backendQuantities?[date] = healthQuantity
        setMovingAverageDatedWeights()
    }
    
    func focusedTypeChanged(old: HealthType?, new: HealthType?) {
        guard old == .weight, new == nil else { return }
        updateBackend(with: userEnteredHealthQuantity)
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
extension WeightForm.Model {
    
    func fetchBackendData() async throws {
        switch formType {
        case .adaptiveSample:
            /// Fetch the backend data for the maximum range for when we use "Moving Average"
            /// Get the maximum possible date range, that being `2 weeks` from date, backwards
            let range = date.moveDayBy(-14)...date
            let quantities = try await healthModel.delegate.weights(for: range)
            
            await MainActor.run {
                self.backendQuantities = quantities
                self.setMovingAverageDatedWeights()
            }
            
        default:
            break
        }
    }
    
    func setMovingAverageDatedWeights() {
        guard let dayCount = sample?.movingAverageInterval?.numberOfDays else {
            movingAverageDatedWeights = []
            return
        }
        
        for i in 0..<dayCount {
            let date = date.moveDayBy(-i)
            let datedWeight: DatedWeight = if let healthQuantity = backendQuantities?[date] {
                .init(date: date, healthQuantity: healthQuantity)
            } else {
                .init(date: date)
            }
            movingAverageDatedWeights[i] = datedWeight
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

        case .adaptiveSample, .specificDate:
            let quantities = try await HealthStore.daysWeights(in: .kg, for: date)?
                .removingDuplicateQuantities()
            
            await MainActor.run {
                self.healthKitQuantities = quantities
                if source == .healthKit {
                    setHealthKitQuantity()
                }
            }

        }
    }
    
    func setHealthKitQuantity() {
        let value: Double? = switch useDailyAverage {
        case true:
            /// Set daily average
            healthKitQuantities?.averageValue?.rounded(toPlaces: 2)
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
                setSampleValue(quantity?.value)
            case .specificDate:
                self.value = quantity?.value
            }
        }
        
        /// If we're not using daily average, and the date of the quantity matches the date of the form, update the backend with it
        if quantity?.date == self.date, !useDailyAverage {
            updateBackend(with: .init(source: .healthKit, isDailyAverage: false, quantity: quantity))
        }
    }
    
    func setSampleValue(_ value: Double?) {
        sample?.value = value
        switch formType.isPreviousSample {
        case true:
            healthModel.health.maintenance?.adaptive.weightChange.previous.value = value
        case false:
            healthModel.health.maintenance?.adaptive.weightChange.current.value = value
        default:
            break
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

extension WeightForm.Model {
    
//    var weightChange: WeightChange? {
//        get {
//            healthModel.health.maintenance?.adaptive.weightChange
//        }
//        set {
//            guard let newValue else { return }
//            healthModel.health.maintenance?.adaptive.weightChange = newValue
//        }
//    }
//    
//    var newSample: WeightSample? {
//        get {
//            switch formType {
//            case .adaptiveSample(let isPrevious):
//                isPrevious ? weightChange?.previous : weightChange?.current
//            default:
//                nil
//            }
//        }
//        set {
//            guard let newValue else { return }
//            switch formType {
//            case .adaptiveSample(let isPrevious):
//                if isPrevious {
//                    weightChange?.previous = newValue
//                } else {
//                    weightChange?.current = newValue
//                }
//            default:
//                break
//            }
//        }
//    }
    
    var isUserEntered: Bool {
        switch formType {
        case .adaptiveSample:
            sampleSource == .userEntered
        default:
            source == .userEntered
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
        case .specificDate:
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
                guard let value else { return nil }
//                guard let value = healthKitValueForDate else { return nil }
                return BodyMassUnit.kg.convert(value, to: unit)
            case .movingAverage:
                return 69.0
            default:
                return nil
            }
            
        case .specificDate:
            switch source {
            case .healthKit:
                guard let value else { return nil }
//                guard let value = healthKitValueForDate else { return nil }
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

extension WeightForm.Model {
    
    var shouldShowTextFieldSection: Bool {
        switch formType {
        case .healthDetails, .specificDate:
            source == .userEntered
        case .adaptiveSample:
            sampleSource == .userEntered
        }
    }
    
    var shouldShowMovingAverageSections: Bool {
        formType.isAdaptiveSample
        && sampleSource == .movingAverage
    }
    
    var shouldShowDailyAverageSection: Bool {
        switch formType {
        case .healthDetails, .specificDate:
            source == .healthKit
        case .adaptiveSample:
            sampleSource == .healthKit
        }
    }
    
    var shouldShowDailyAverageValuesSection: Bool {
        switch formType {
        case .healthDetails, .specificDate:
            source == .healthKit && useDailyAverage
        case .adaptiveSample:
            sampleSource == .healthKit && useDailyAverage
        }
    }
    
    var shouldShowDate: Bool {
        switch formType {
        case .healthDetails:
            source == .healthKit
        case .specificDate:
            source == .healthKit && !useDailyAverage
        default:
            false
        }
    }
}

extension WeightForm.Model {
    
    var sourceBinding: Binding<HealthSource> {
        Binding<HealthSource>(
            get: { self.source ?? .userEntered },
            set: { newValue in
                withAnimation {
                    self.source = newValue
                }
                
                switch self.formType {
                case .healthDetails:
                    /// [ ] We might have to stop syncing weight from healthKit whenever biometrics change since we're doing it in the form
                    self.healthModel.health.weight?.source = newValue
                    switch newValue {
                    case .healthKit:
                        self.setHealthKitQuantity()
                    case .userEntered:
                        break
                    }
                    
                case .specificDate:
                    
                    /// Update the backend and send a notification so that the form for the sample can update itself

                    let healthQuantity: HealthQuantity
                    switch newValue {
                    case .healthKit:
                        self.setHealthKitQuantity()
                        healthQuantity = self.healthKitHealthQuantity
                        
                    case .userEntered:
                        healthQuantity = self.userEnteredHealthQuantity
                    }
                    
                    self.updateBackend(with: healthQuantity)
                    let userInfo: [Notification.PrepSettingsKeys : Any] = [
                        .date: self.date,
                        .weightHealthQuantity: healthQuantity
                    ]

                    /// [ ] Send a notification
                    post(.didUpdateWeight, userInfo)
                    
                    /// [ ] Receive notification HealthModel and update itself if date pertains to it (is the date itself or the date that its using)
                    /// [ ] Receive notification in WeightForm, and if date pertains to it (if its an average component or its health details uses it—actually this should be handled by HealthModel itself receiving the notification—then update itself)
                   
                    /// [ ] Modify the update backend function or at least add notes to imply that we'll be triggering changes in all the Health structs that the weight pertains to (in Health.Weight or as adaptive sample), and if we have a change there, updating the plan if its dependent on those components too;

                case .adaptiveSample:
                    /// Not handled here (we use `sampleSourceBinding` instead
                    break
                }
            }
        )
    }
    
    func updateBackend(with healthQuantity: HealthQuantity) {
        Task {
            try await self.healthModel.delegate.handleWeightChange(
                for: self.date,
                with: healthQuantity
            )
        }
    }
    
    var healthKitHealthQuantity: HealthQuantity {
        HealthQuantity(
            source: .healthKit,
            isDailyAverage: self.isDailyAverage ?? false,
            quantity: self.healthKitLatestQuantity
        )
    }
    
    var userEnteredHealthQuantity: HealthQuantity {
        HealthQuantity(
            source: .userEntered,
            isDailyAverage: false,
            quantity: .init(value: self.value)
        )
    }
    
    var sampleSourceBinding: Binding<WeightSampleSource> {
        Binding<WeightSampleSource>(
            get: { 
                self.sampleSource ?? .userEntered
            },
            set: { newValue in
                
                withAnimation {
                    self.sampleSource = newValue
//                    self.sampleSource = newValue
                }
                
                switch newValue {
                case .healthKit:
                    self.setHealthKitQuantity()
                    self.updateBackend(with: self.healthKitHealthQuantity)

                case .movingAverage:
                    self.setMovingAverageValue()

                case .userEntered:
                    self.updateBackend(with: self.userEnteredHealthQuantity)
                }
                
                //TODO: Actually change the value now
                /// [x] Update the actual `WeightSample`

                switch self.formType.isPreviousSample {
                case true:
                    self.healthModel.health.maintenance?.adaptive.weightChange.previous.source = newValue
                case false:
                    self.healthModel.health.maintenance?.adaptive.weightChange.current.source = newValue
                default:
                    break
                }
            }
        )
    }
    
    func setMovingAverageValue() {
        guard let interval = sample?.movingAverageInterval else { return }
        
        var values: [Double] = []
        for index in 0..<interval.numberOfDays {
            guard let value = backendValue(at: index) else { continue }
            values.append(value)
        }
        setSampleValue(values.averageValue?.rounded(toPlaces: 2))
//        //TODO: Rewrite this
//        guard let values = sample?.movingAverageValues,
//              let average = Array(values.values).averageValue
//        else {
//            self.sample?.value = nil
//            return
//        }
//        self.sample?.value = average
    }
    
    var useDailyAverage: Bool {
        get {
            switch formType {
            case .healthDetails:
                healthModel.health.weight?.isDailyAverage ?? false
            case .specificDate:
                isDailyAverage == true
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
            case .specificDate:
                withAnimation {
                    isDailyAverage = newValue
                }
            case .adaptiveSample:
                withAnimation {
                    sample?.isDailyAverage = newValue
                }
            }
            setHealthKitQuantity()
        }
    }
    
    var movingAverageIntervalPeriod: HealthPeriod {
        get { sample?.movingAverageInterval?.period ?? .default }
        set {
            guard let sample else { return }
            var interval = sample.movingAverageInterval ?? .default
            interval.period = newValue
            setMovingAverageDatedWeights()
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

    func backendHealthQuantity(at index: Int) -> HealthQuantity? {
        let date = self.date.moveDayBy(-index)
        return backendQuantities?[date]
    }
    
    func backendQuantity(at index: Int) -> Quantity? {
        backendHealthQuantity(at: index)?.quantity
    }
    
    func backendSource(at index: Int) -> HealthSource? {
        backendHealthQuantity(at: index)?.source
    }
    
    func backendValue(at index: Int) -> Double? {
        guard let quantity = backendQuantity(at: index) else { return nil }
        return BodyMassUnit.kg.convert(quantity.value, to: SettingsStore.bodyMassUnit)
    }
}
