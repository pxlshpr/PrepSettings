import SwiftUI
import PrepShared

/// [ ] Store healthKit quantities along with weight when saving (to account for averages) – do this in HealthQuantity struct itself maybe
/// [ ] Revisit the updateBackend thing with our current thinking, and maybe treat past health details differently

/// [ ] Consider having different units, by first renaming `value` to `valueInKg`, then addressing every place we use it
/// [ ] Also consider different units for the two other form types

extension WeightForm {
    @Observable class Model {
        
        let formType: WeightFormType
        let healthModel: HealthModel
        var date: Date

        var valueInKg: Double?
        var valueString: String?
        var valueSecondComponentString: String?
        
//        var sample: WeightSample?
        var isDailyAverage: Bool?
        var sampleSource: WeightSampleSource?
        var sampleMovingAverage: WeightSample.MovingAverage?
        var source: HealthSource?
        var isRemoved: Bool

        var healthKitQuantities: [Quantity]?
        
        /// Reference values kept so that when changing interval we're able to display values quickly without re-querying for them
//        var backendWeights: [Date: HealthDetails.Weight]?
        
        /// List of moving average weights that are displayed based on the current interval
        var movingAverageWeights: [HealthDetails.Weight] = []
        
        /// HealthDetails init
        init(
            healthModel: HealthModel
        ) {
            self.formType = .healthDetails
            self.healthModel = healthModel
            self.date = healthModel.health.date
            
            let weight = healthModel.health.weight
            
            let valueInKg = weight?.valueInKg
            self.valueInKg = valueInKg
            if SettingsStore.bodyMassUnit == .st, let valueInKg {
                let valueInSt = BodyMassUnit.kg.convert(valueInKg, to: .st)
                self.valueString = "\(valueInSt.stonesComponent)"
                self.valueSecondComponentString = valueInSt.poundsComponent.clean
            } else {
                self.valueString = weight?.value(in: SettingsStore.bodyMassUnit)?.cleanWithoutRounding
            }
            
            self.source = weight?.source
            self.isDailyAverage = weight?.isDailyAverage
            
            self.isRemoved = weight == nil
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
            
            self.valueInKg = sample.value
            self.sampleSource = sample.source
            self.isDailyAverage = sample.isDailyAverage
            self.sampleMovingAverage = sample.movingAverage

//            self.sample = sample
            self.isRemoved = false

            /// Initialize movingAverageDatedWeights with empty placeholders
            self.movingAverageWeights = sample.movingAverage?.weights ?? []
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
            
            self.valueInKg = value
            self.source = source ?? .userEntered
            self.isDailyAverage = isDailyAverage
            
            self.isRemoved = false
        }
    }
}

extension WeightForm.Model {
    
    func cancelEditing() {
        switch formType {
        case .healthDetails:
            let weight = healthModel.health.weight
            self.valueInKg = weight?.valueInKg
            self.source = weight?.source
            self.isDailyAverage = weight?.isDailyAverage
            self.isRemoved = healthModel.health.weight == nil
        default:
            break
        }
    }
    
    func doneEditing() {
        switch formType {
        case .healthDetails:
            if valueInKg == nil {
                removeWeight()
            }
            if isRemoved {
                healthModel.health.weight = nil
            } else {
                healthModel.health.weight = weight
            }
        default:
            break
        }
    }
    
    func startEditing() {
        switch formType {
        case .healthDetails:
            switch source {
            case .healthKit:
                /// Recalculate average
                setHealthKitQuantity()
            default:
                break
            }
        default:
            break
        }
    }
}

extension WeightForm.Model {
    
    var weight: HealthDetails.Weight {
        .init(
            source: source ?? .userEntered,
            isDailyAverage: source == .healthKit ? isDailyAverage ?? false : false,
            healthKitQuantities: source == .healthKit ? healthKitQuantities : nil,
            valueInKg: valueInKg
        )
    }
    
//    var valueInKg: Double? {
//        guard let value else { return nil }
//        return SettingsStore.bodyMassUnit.convert(value, to: .kg)
//    }
    
    
    func textFieldValueChanged(to value: Double?) {
        self.valueInKg = value
        
        if healthModel.isCurrent {
            switch formType {
            case .healthDetails:
                healthModel.health.weight?.valueInKg = valueInKg

            case .adaptiveSample:
                setSampleValue(value)

            case .specificDate:
                self.valueInKg = value
            }
        }
    }
    
    func handleNewSource(_ source: HealthSource) {
        withAnimation {
            self.source = source
        }
        
        switch formType {
        case .healthDetails:
            /// [ ] We might have to stop syncing weight from healthKit whenever biometrics change since we're doing it in the form
            if healthModel.isCurrent {
                healthModel.health.weight?.source = source
            }
            
            switch source {
            case .healthKit:
                self.setHealthKitQuantity()
            case .userEntered:
                break
            }

        case .specificDate:
            
            /// Update the backend and send a notification so that the form for the sample can update itself

            let healthQuantity: HealthQuantity
            switch source {
            case .healthKit:
                self.setHealthKitQuantity()
//                healthQuantity = healthKitHealthQuantity
                
            case .userEntered:
                break
//                healthQuantity = userEnteredHealthQuantity
            }
            
//            updateBackend(with: healthQuantity)
            
            /// [ ] Receive notification HealthModel and update itself if date pertains to it (is the date itself or the date that its using)
            /// [ ] Receive notification in WeightForm, and if date pertains to it (if its an average component or its health details uses it—actually this should be handled by HealthModel itself receiving the notification—then update itself)
           
            /// [ ] Modify the update backend function or at least add notes to imply that we'll be triggering changes in all the Health structs that the weight pertains to (in Health.Weight or as adaptive sample), and if we have a change there, updating the plan if its dependent on those components too;

        case .adaptiveSample:
            /// Not handled here (we use `sampleSourceBinding` instead
            break
        }
    }
}

extension WeightForm.Model {
    var disabledSampleSources: [WeightSampleSource] {
        guard !healthModel.isLocked else {
            return WeightSampleSource.allCases
        }
        return if healthKitQuantities?.isEmpty == false {
            []
        } else {
            [.healthKit]
        }
    }
    
    var disabledSources: [HealthSource] {
        
        if healthModel.isLocked {
            return HealthSource.allCases
        }
        
        guard formType != .healthDetails else {
            return []
        }
        return if healthKitQuantities?.isEmpty == false {
            []
        } else {
            [.healthKit]
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
extension WeightForm.Model {
    
//    func fetchBackendData() async throws {
//        switch formType {
//        case .adaptiveSample:
//            /// Fetch the backend data for the maximum range for when we use "Moving Average"
//            /// Get the maximum possible date range, that being `2 weeks` from date, backwards
//            let range = date.moveDayBy(-14)...date
//            let weights = try await healthModel.delegate.weights(for: range)
//            
//            await MainActor.run {
//                self.backendWeights = weights
////                self.setMovingAverageDatedWeights()
//            }
//            
//        default:
//            break
//        }
//    }
    
    func fetchHealthKitData() async throws {
        guard !isPreview else {
            await MainActor.run {
                self.healthKitQuantities = mockWeightQuantities(for: date)
            }
            return
        }
        
        switch formType {
        case .healthDetails:
            /// [ ] Fetch the latest day's values from HealthKit
            /// [ ] Keep this stored in the model
            /// [ ] If this value exists (ie is stored), only then show the Apple Health option in source
            let quantities = try await HealthStore.latestDayOfWeightQuantities(for: date)
            
            await MainActor.run {
                self.healthKitQuantities = quantities
                if source == .healthKit {
                    setHealthKitQuantity()
                }
            }

        case .adaptiveSample, .specificDate:
            let quantities = try await HealthStore.weightQuantities(on: date)?
                .removingDuplicateQuantities()
            
            await MainActor.run {
                self.healthKitQuantities = quantities
                if source == .healthKit {
                    setHealthKitQuantity()
                }
            }

        }
    }
    
    var isHealthKit: Bool {
        switch formType {
        case .adaptiveSample:   sampleSource == .healthKit
        default:                source == .healthKit
        }
    }

    var isUserEntered: Bool {
        switch formType {
        case .adaptiveSample:   sampleSource == .userEntered
        default:                source == .userEntered
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
        
        withAnimation {
            self.valueInKg = value
        }

        /// Persist value
        if healthModel.isCurrent {
            switch formType {
            case .healthDetails:
                healthModel.health.weight = weight
            case .adaptiveSample:
                setSampleValue(value)
            case .specificDate:
                break
            }
            
            //TODO: Revisit this
            /// If the date of the quantity is on the same day as the date of the form, update the backend with it
//            if date?.startOfDay == self.date.startOfDay {
//                updateBackend(with: healthKitHealthQuantity)
//            }
        }
    }
    
    func setSampleValue(_ value: Double?) {
        
        self.valueInKg = value
        
        if healthModel.isCurrent {
            switch formType.isPreviousSample {
            case true:
                healthModel.health.maintenance?.adaptive.weightChange.previous.value = value
            case false:
                healthModel.health.maintenance?.adaptive.weightChange.current.value = value
            default:
                break
            }
        }
    }
    
    func setWeight() {
        withAnimation {
            isRemoved = false
            switch formType {
            case .healthDetails:
                valueInKg = nil
                source = .userEntered
                isDailyAverage = nil
                if healthModel.isCurrent {
                    healthModel.health.weight = weight
                }
            case .adaptiveSample:
                valueInKg = nil
                sampleSource = .userEntered
                isDailyAverage = nil
            default:
                break
            }
        }
    }
    
    func removeWeight() {
        switch formType {
        case .healthDetails:
            withAnimation {
                isRemoved = true
                if healthModel.isCurrent {
                    healthModel.remove(.weight)
                } else {
                    valueInKg = nil
                    isDailyAverage = nil
                    source = .userEntered
                }
            }
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
    
    var footerString: String? {
        switch formType {
        case .healthDetails:
            HealthType.weight.reason!
        default:
            nil
        }
    }
    
    var healthKitLatestQuantity: Quantity? {
        healthKitQuantities?.last
    }
    
    func computedValue(in unit: BodyMassUnit) -> Double? {
        switch formType {
        case .healthDetails:
            return valueInKg
//            switch source {
//            case .healthKit:
//                guard let value = healthModel.health.weight?.quantity?.value else { return nil }
//                return BodyMassUnit.kg.convert(value, to: unit)
//            default:
//                return nil
//            }
            
        case .adaptiveSample:
            switch sampleSource {
            case .healthKit:
                guard let valueInKg else { return nil }
//                guard let value = healthKitValueForDate else { return nil }
                return BodyMassUnit.kg.convert(valueInKg, to: unit)
            case .movingAverage:
                return 69.0
            default:
                return nil
            }
            
        case .specificDate:
            switch source {
            case .healthKit:
                guard let valueInKg else { return nil }
//                guard let value = healthKitValueForDate else { return nil }
                return BodyMassUnit.kg.convert(valueInKg, to: unit)
            default:
                return nil
            }
        }
    }
    
    var quantity: Quantity? {
        guard let valueInKg else { return nil }
        return .init(value: valueInKg, date: date)
    }
}

extension WeightForm.Model {
    
    var shouldShowHealthKitError: Bool {
        formType == .healthDetails
        && source == .healthKit
//        && healthModel.health.weight?.quantity?.value == nil
        && valueInKg == nil
        && !healthModel.isLocked
    }
    
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
            sampleSource == .healthKit
//            sampleSource == .healthKit && useDailyAverage
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
            set: { self.handleNewSource($0) }
        )
    }
    
    func updateBackend(with healthQuantity: HealthQuantity?) {
        Task {
            try await self.healthModel.delegate.handleWeightChange(
                for: self.date,
                with: healthQuantity
            )
        }
    }
    
    //    var healthKitHealthQuantity: HealthQuantity {
    //        let isDailyAverage = switch formType {
    //        case .healthDetails:    healthModel.health.weight?.isDailyAverage
    //        case .specificDate:     isDailyAverage
    //        case .adaptiveSample:   sample?.isDailyAverage
    //        }
    //        return HealthQuantity(
    //            source: .healthKit,
    //            isDailyAverage: isDailyAverage ?? false,
    ////            quantity: self.healthKitLatestQuantity
    //            quantity: healthModel.health.weight?.quantity
    //        )
    //    }
    //
    //    var userEnteredHealthQuantity: HealthQuantity {
    //        let value = switch formType {
    //        case .healthDetails:
    //            healthModel.health.weight?.quantity?.value
    //        case .adaptiveSample:
    //            sample?.value
    //        case .specificDate:
    //            self.value
    //        }
    //
    //        return HealthQuantity(
    //            source: .userEntered,
    //            isDailyAverage: false,
    //            quantity: .init(value: value)
    //        )
    //    }
    
    var sampleSourceBinding: Binding<WeightSampleSource> {
        Binding<WeightSampleSource>(
            get: {
                self.sampleSource ?? .userEntered
            },
            set: { newValue in
                
                withAnimation {
                    self.sampleSource = newValue
                }
                
                switch newValue {
                case .healthKit:        self.setHealthKitQuantity()
                case .movingAverage:    self.setMovingAverageValue()
                case .userEntered:      break
                }
                
                self.updateSampleIfNeeded()
            }
        )
    }
    
    var useDailyAverage: Bool {
        get { isDailyAverage == true }
        set {
            withAnimation {
                isDailyAverage = newValue
            }
            
            setHealthKitQuantity()

            if healthModel.isCurrent {
                switch formType {
                case .healthDetails:    healthModel.health.weight?.isDailyAverage = newValue
                case .specificDate:     break
                case .adaptiveSample:   self.updateSampleIfNeeded()
                }
            }
        }
    }
}

extension WeightForm.Model {
    
    func setMovingAverageValue() {
        guard let interval = sampleMovingAverage?.interval else { return }
        
        Task {
            var weights: [HealthDetails.Weight] = []
            for index in 0..<interval.numberOfDays {

                let date = self.date.moveDayBy(-index)
                let weight = if index < self.movingAverageWeights.count {
                    /// If we already have a value for this—use it
                    movingAverageWeights[index]
                } else {
                    /// Otherwise query the backend for it
                    try await healthModel.delegate.weight(for: date)
                }
                if let weight {
                    weights.append(weight)
                } else {
                    /// [ ] Empty values
                    weights.append(.init(source: .userEntered))
                }
            }
            
            await MainActor.run { [weights] in
                withAnimation {
                    movingAverageWeights = weights
                    setSampleValue(weights.averageValue?.rounded(toPlaces: 2))
                }
            }
        }
    }
    
    func updateSampleIfNeeded() {
        guard healthModel.isCurrent else {
            return
        }
        
        //TODO: give WeightChange all the current variables pertaining to it with isPrevious
//        switch self.formType.isPreviousSample {
//        case true:
//            self.healthModel.health.maintenance?.adaptive.weightChange.previous.source = sampleSource
//        case false:
//            self.healthModel.health.maintenance?.adaptive.weightChange.current.source = sampleSource
//        default:
//            break
//        }
        
//        healthModel.health.maintenance?.adaptive.weightChange
//            .setIsDailyAverage(newValue, forPrevious: isPrevious)
    }
}
