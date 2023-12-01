import SwiftUI
import PrepShared

struct DietaryEnergySamplesList: View {
    
    @Environment(SettingsStore.self) var settingsStore: SettingsStore
    @Environment(HealthModel.self) var healthModel: HealthModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Form {
            samplesSection
        }
        .navigationTitle("Dietary Energy")
    }
    
    var samplesSection: some View {
        Section {
            ForEach(0..<maintenance.dietaryEnergy.samples.count, id: \.self) {
                dietaryEnergyCell(
                    sample: maintenance.dietaryEnergy.samples[$0],
                    date: DietaryEnergy.dateForSample(at: $0, for: date)
                )
            }
        }
    }
    
    var logMissingDaysAsEmptySection: some View {
        var footer: some View {
            Text("Days without dietary energy will automatically use the average. Tap this to explicitly mark those days as having consumed no dietary energy.")
        }
        
        return Section(footer: footer) {
            Button("Log missing days with 0 kcal") {
                
            }
        }
    }
    
    enum Route: Hashable {
        case sample(DietaryEnergySample, Date)
    }
    
    func dietaryEnergyCell(sample: DietaryEnergySample, date: Date) -> some View {
        NavigationLink(value: Route.sample(sample, date)) {
            DietaryEnergySampleCell(sample: sample, date: date)
        }
        .navigationDestination(for: Route.self) { route in
            switch route {
            case .sample(let sample, let date):
                DietaryEnergySampleForm(
                    sample: sample,
                    date: date,
                    healthModel: healthModel,
                    settingsStore: settingsStore,
                    didSave: { sample in
                        healthModel.setDietaryEnergySample(sample, for: date)
                    }
                )
            }
        }
    }
    
    var maintenance: Health.MaintenanceEnergy {
        healthModel.health.maintenanceEnergy ?? .init()
    }
    
    var date: Date {
        healthModel.health.date
    }
}
