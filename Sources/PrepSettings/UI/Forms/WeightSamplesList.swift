import SwiftUI
import PrepShared

struct WeightSamplesList: View {
    
    @Environment(SettingsStore.self) var settingsStore: SettingsStore
    @Environment(HealthModel.self) var healthModel: HealthModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Form {
            Section {
                weightCell(sample: maintenance.weightChange.current, isPrevious: false)
            }
            Section("Previous") {
                weightCell(sample: maintenance.weightChange.previous, isPrevious: true)
            }
            Section {
                maintenance.weightChangeRow(bodyMassUnit: settingsStore.bodyMassUnit)
                maintenance.equivalentEnergyRow(energyUnit: settingsStore.energyUnit)
            }
//            fillAllFromHealthAppSection
        }
        .navigationTitle("Weight")
    }
    
    func weightCell(sample: WeightSample, isPrevious: Bool) -> some View {
        
        var date: Date {
            isPrevious ? previousDate : currentDate
        }
        
        func didSaveWeight(_ sample: WeightSample) {
            healthModel.setWeightSample(sample, isPrevious: isPrevious)
//            dismiss()
        }
        
        return NavigationLink {
            WeightSampleForm(
                sample: sample,
                date: date,
                healthModel: healthModel,
                settingsStore: settingsStore,
                didSave: didSaveWeight
            )
        } label: {
            WeightSampleCell(sample: sample, date: date)
                .environment(settingsStore)
        }
    }
    
    var currentDate: Date {
        healthModel.health.date
    }
    
    var previousDate: Date {
        maintenance.interval.startDate(with: currentDate)
    }

    var maintenance: Health.MaintenanceEnergy {
        healthModel.health.maintenanceEnergy ?? .init()
    }
}
