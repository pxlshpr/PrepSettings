import SwiftUI
import PrepShared

enum WeightChangeType: CaseIterable {
    case usingWeights
    case userEntered
    
    var name: String {
        switch self {
        case .usingWeights: "Using Weights"
        case .userEntered:  "Entered Manually"
        }
    }
}

struct WeightSamplesList: View {
    
    @Environment(SettingsStore.self) var settingsStore: SettingsStore
    @Environment(HealthModel.self) var healthModel: HealthModel
    @Environment(\.dismiss) var dismiss
    
    @State var type: WeightChangeType = .usingWeights
    
    var body: some View {
        Form {
            weightChangeSection
            sourceSection
            weightsSections
        }
        .navigationTitle("Weight Change")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    var weightsSections: some View {
        if type == .usingWeights {
            Section("Current") {
                weightCell(sample: maintenance.weightChange.current, isPrevious: false)
            }
            Section("Previous") {
                weightCell(sample: maintenance.weightChange.previous, isPrevious: true)
            }
        }
    }
    
    var weightChangeSection: some View {
        
        let unitBinding = Binding<BodyMassUnit>(
            get: { settingsStore.bodyMassUnit },
            set: { newValue in
                withAnimation {
                    settingsStore.bodyMassUnit = newValue
                }
            }
        )
        @ViewBuilder
        var row: some View {
            HStack {
                Text("21 - 28 August 2021")
                Spacer()
                switch type {
                case .usingWeights:
                    maintenance.weightChangeValueText(bodyMassUnit: settingsStore.bodyMassUnit)
                case .userEntered:
                    ManualHealthField(
                        unitBinding: unitBinding,
                        valueBinding: .constant(0),
                        firstComponentBinding: .constant(0),
                        secondComponentBinding: .constant(0)
                    )
                }
            }
        }
        
        var footer: some View {
            var string: String {
                switch type {
                case .usingWeights:
                    "Your weight change is being calculated by using your current and previous weights."
                case .userEntered:
                    "Your are a using a custom entered weight change."
                }
            }
            return Text(string)
        }
        
        return Section(footer: footer) {
            row
        }
    }
    
    var sourceSection: some View {
        let selection = Binding<WeightChangeType>(
            get: { type },
            set: { newValue in
                withAnimation {
                    type = newValue
                }
            }
        )

        return Picker("Source", selection: selection) {
            ForEach(WeightChangeType.allCases, id: \.self) {
                Text($0.name)
            }
        }
        .pickerStyle(.inline)
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

#Preview {
    NavigationStack {
        WeightSamplesList()
            .environment(SettingsStore.shared)
            .environment(MockHealthModel)
            .onAppear {
                SettingsStore.configureAsMock()
            }
    }
}
