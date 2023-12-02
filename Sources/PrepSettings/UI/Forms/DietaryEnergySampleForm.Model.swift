import SwiftUI
import PrepShared

extension DietaryEnergySampleForm {
    @Observable class Model {
        let initialSample: DietaryEnergySample
        var sample: DietaryEnergySample
        
        let date: Date
        var displayedValue: Double?
        
        var fetchedValuesInKcal: [DietaryEnergySampleType: Double] = [:]

        var type: DietaryEnergySampleType
        
        let healthModel: HealthModel

        init(sample: DietaryEnergySample, date: Date, healthModel: HealthModel) {
            
            var sample = sample
            if sample.type == .average {
                sample.value = nil
            }
            
            self.initialSample = sample
            self.sample = sample
            self.date = date
            self.type = sample.type
            self.healthModel = healthModel
            
            if let value = sample.value {
                self.displayedValue = EnergyUnit.kcal.convert(value, to: SettingsStore.shared.energyUnit)
            } else {
                self.displayedValue = 0
            }
        }

    }
}

extension DietaryEnergySampleForm.Model {
    
    var saveIsDisabled: Bool {
        initialSample == sample
    }
    
    func selected(_ type: DietaryEnergySampleType) {
        self.type = type
        if type != .userEntered {
            sample.value = value(
                for: type,
                in: SettingsStore.energyUnit
            )
        } else {
            displayedValue = sample.value?.rounded() ?? 0
        }
        sample.type = type
    }
    
    func setValue(energyUnit: EnergyUnit) {
        let typesToCheck: [DietaryEnergySampleType] = [.logged, .healthKit]
        for type in typesToCheck {
            if let value = value(for: type, in: energyUnit) {
                sample.value = value
                sample.type = type
                displayedValue = EnergyUnit.kcal.convert(value, to: energyUnit)
                self.type = type
                return
            }
        }
        
        /// If we still haven't got a value
        sample.value = 0
        displayedValue = 0
        type = .userEntered
    }
    
    var hasValue: Bool {
        sample.value != nil
    }
    
    func haveValue(for type: DietaryEnergySampleType) -> Bool {
        fetchedValuesInKcal[type] != nil
    }
    
    func value(for type: DietaryEnergySampleType, in unit: EnergyUnit) -> Double? {
        switch type {
        case.userEntered:
            return 0
        default:
            guard let value = fetchedValuesInKcal[type] else {
                return nil
            }
            return EnergyUnit.kcal.convert(value, to: unit)
        }
    }
    
    func removeValue() {
        sample.value = nil
        displayedValue = 2000
    }
    
//    func valueInKcal(for type: DietaryEnergySampleType) -> Double? {
//        switch type {
//        case .userEntered:  displayedValue
//        default:            fetchedValuesInKcal[type]
//        }
//    }
    
    @Sendable
    func loadValues() async {
        
        do {
            var values: [DietaryEnergySampleType: Double] = [:]
            if let value = try await healthModel.delegate.dietaryEnergyInKcal(on: date) {
                values[.logged] = value
            }
            
            if !isPreview {
                if let value = try await HealthStore.dietaryEnergyTotalInKcal(for: date) {
                    values[.healthKit] = value
                }
            }

            await MainActor.run { [values] in
                fetchedValuesInKcal = values
            }

        } catch {
            
        }
    }
}
