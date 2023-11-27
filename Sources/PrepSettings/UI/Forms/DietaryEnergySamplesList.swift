import SwiftUI
import PrepShared

struct DietaryEnergySamplesList: View {
    
    @Environment(SettingsStore.self) var settingsStore: SettingsStore
    @Environment(HealthModel.self) var healthModel: HealthModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Form {
            samplesSection
            logMissingDaysAsEmptySection
        }
        .navigationTitle("Dietary Energy")
    }
    
    var samplesSection: some View {
        var footer: some View {
            Text("You can choose to disregard days that were inaccurately or incompletely logged by setting them to use the average.")
        }
        
        return Section(footer: footer) {
            ForEach(0..<maintenance.dietaryEnergy.samples.count, id: \.self) {
                dietaryEnergyCell(
                    sample: maintenance.dietaryEnergy.samples[$0],
                    date: date.moveDayBy(-$0)
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
    
    func dietaryEnergyCell(sample: MaintenanceDietaryEnergySample, date: Date) -> some View {
        NavigationLink {
            DietaryEnergySampleForm(
                sample: sample,
                date: date,
                healthModel: healthModel,
                settingsStore: settingsStore,
                didSave: { value in
                    
                }
            )
//            EmptyView()
//            WeightSampleForm(sample: sample, date: date)
        } label: {
            DietaryEnergySampleCell(sample: sample, date: date)
        }
    }
    
    var maintenance: Health.MaintenanceEnergy {
        healthModel.health.maintenanceEnergy ?? .init()
    }
    
    var date: Date {
        healthModel.health.date
    }
}
