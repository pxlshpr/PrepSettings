import SwiftUI
import PrepShared

struct MaintenanceAdaptiveForm: View {
    
    @Environment(SettingsStore.self) var settingsStore: SettingsStore

    @Bindable var healthModel: HealthModel
    
    @State var hasAppeared = false
    @State var useMovingAverageForWeight = true
    @State var showingWeightConversionInfo = false

    init(_ model: HealthModel) {
        self.healthModel = model
    }
    
    var body: some View {
        Group {
            if hasAppeared {
                content
            } else {
                Color.clear
            }
        }
        .navigationTitle("Adaptive Maintenance")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: appeared)
    }
    
    func appeared() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            hasAppeared = true
        }
    }
    
    var content: some View {
        List {
            section
            fetchFromHealthKitSection
//            daysSection
//            weightSection
//            dietaryEnergySection
            calculatedSection
        }
        .navigationDestination(for: Route.self) { route in
            switch route {
            case .weightSamples:
                WeightChangeForm(healthModel)
                    .environment(settingsStore)
            case .dietaryEnergySamples:
                DietaryEnergySamplesList()
                    .environment(settingsStore)
                    .environment(healthModel)
            }
        }
    }
    
    var fetchFromHealthKitSection: some View {
        Section {
            Button("Fetch Available Data") {
                Task {
                    try await healthModel.calculateAdaptiveMaintenance()
                }
            }
        }
    }
    
    var section: some View {
        var footer: some View {
            Text("Your weight change will be compared to the total dietary energy you consumed over the specified period to determine your maintenance energy.")
        }
        return Section(footer: footer) {
            periodRow
            weightChangeRow
            dietaryEnergyRow
        }
    }
    
    var maintenance: Health.Maintenance {
        healthModel.health.maintenance ?? .init()
    }
    
    var date: Date {
        healthModel.health.date
    }

    var weightSection: some View {
        Section {
            weightChangeRow
        }
    }
    
    var dietaryEnergyRow: some View {
        NavigationLink(value: Route.dietaryEnergySamples) {
            HStack {
                Text("Dietary Energy")
                Spacer()
                if let total = maintenance.adaptive.dietaryEnergy.total {
                    Text("\(total.formattedEnergy) kcal")
                        .foregroundStyle(.secondary)
                } else {
                    Text("Not enough data")
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }

    var dietaryEnergySection: some View {
        Section {
            dietaryEnergyRow
        }
    }

    var weightSection_: some View {
        var footer: some View {
            VStack(alignment: .leading, spacing: 5) {
                Text("Change in your weight over the prior 7 days, converted to energy.")
                Button("Learn More") {
                    showingWeightConversionInfo = true
                }
                .font(.footnote)
            }
            .sheet(isPresented: $showingWeightConversionInfo) {
                NavigationStack {
                    Form {
                        Text("The conversion is done using the old research that 1 lb of body fat equals 3500 kcal.")
                        Text("This is no longer considered accurate, and you usually lose a mix of fat, lean tissue and water.")
                        Text("We are still using this value as it's the best estimation we have to be able to make a calculation.")
                        Text("If you consume a certain amount based on that calculation, and your weight change isn't what you desire it to be—you could keep amending the deficit or surplus until your desired weight change is achieved.")
                        Text("Other factors like inaccuracies in logging your food could also contribute to a less accurate calculation—which is why having this calculation periodically adapt to your observed weight change is more useful than getting it precisely correct.")
                        Text("Also, as your weight change plateaus, this conversion would be even less relevant since the energy change would be 0 regardless.")
                    }
                    .font(.callout)
                    .navigationTitle("Weight to Energy Conversion")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") {
                                showingWeightConversionInfo = false
                            }
                            .fontWeight(.semibold)
                        }
                    }
                }
                .presentationDetents([.medium, .large])
            }
        }
        
        var header: some View {
            Text("Weight Change")
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundStyle(Color(.label))
                .textCase(.none)
        }

        var previousDate: Date {
            maintenance.adaptive.interval.startDate(with: date)
        }
        
        var samplesLink: some View {
            NavigationLink(value: Route.weightSamples) {
                Text("Show Data")
            }
        }
        
        return Group {
//            Section(header: header, footer: footer) {
            Section(header: header) {
                maintenance.adaptive.weightChangeRow(bodyMassUnit: settingsStore.bodyMassUnit)
                maintenance.adaptive.equivalentEnergyRow(energyUnit: settingsStore.energyUnit)
                samplesLink
            }
        }
    }
    
    enum Route {
        case weightSamples
        case dietaryEnergySamples
    }
    
    var daysSection: some View {
        var footer: some View {
            Text("The period over which to compare your weight change against your consumed dietary energy.")
        }
        
        return Section(footer: footer) {
            periodRow
        }
    }
    
    var periodRow: some View {
        HStack {
            Text("Period")
            Spacer()
            Stepper("", value: healthModel.intervalValueBinding, in: healthModel.intervalPeriod.range)
                .fixedSize()
            HStack(spacing: UnitSpacing) {
                Text("\(healthModel.intervalValue)")
                    .font(NumberFont)
                    .contentTransition(.numericText(value: Double(healthModel.intervalValue)))
                    .foregroundStyle(.secondary)
                MenuPicker<HealthPeriod>([.day, .week], healthModel.intervalPeriodBinding)
            }
        }
    }
    
    var weightChangeRow: some View {
        NavigationLink(value: Route.weightSamples) {
            HStack {
                Text("Weight Change")
                Spacer()
                maintenance.adaptive.weightChangeValueText(bodyMassUnit: settingsStore.bodyMassUnit)
            }
        }
    }
    
    var dietaryEnergySection_: some View {
        
        var header: some View {
            Text("Dietary Energy")
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundStyle(Color(.label))
                .textCase(.none)
        }
        
        var footer: some View {
            Text("The energy you consumed over the 7 days leading up to this date.")
        }
        
        var samplesLink: some View {
            NavigationLink(value: Route.dietaryEnergySamples) {
                Text("Show Data")
            }
        }
        
        var totalRow: some View {
            HStack {
                Text("Total Consumed")
                Spacer()
                if let total = maintenance.adaptive.dietaryEnergy.total {
                    Text("\(total.formattedEnergy) kcal")
                        .foregroundStyle(.secondary)
                } else {
                    Text("Not enough data")
                        .foregroundStyle(.tertiary)
                }
            }
        }
        
//        return Section(header: header, footer: footer) {
        return Section(header: header) {
            totalRow
            samplesLink
        }
    }
    
    var calculatedSection: some View {
        var footer: some View {
            Text("The energy needed to maintain your current weight. Consume less or more than this to lose or gain weight.")
        }
        
        var topRow: some View {
            HStack {
                Text("Calculated")
                    .fontWeight(.semibold)
                Spacer()
            }
        }
        
        var valueRow: some View {
            HStack {
//                if maintenance.adaptiveValue != nil {
//                    Image(systemName: "equal")
//                        .foregroundStyle(.secondary)
//                        .font(.title2)
//                        .fontWeight(.heavy)
//                }
                Spacer()
                if let value = maintenance.adaptive.value {
                    LargeHealthValue(
                        value: value,
                        unitString: "\(settingsStore.energyUnit.abbreviation) / day"
                    )
//                    .multilineTextAlignment(.trailing)
                } else {
                    Text("Not enough data")
                        .foregroundStyle(.tertiary)
                }
            }
        }
        
        return Section(footer: footer) {
            VStack {
//                topRow
                valueRow
            }
        }
    }
    
    var fillAllFromHealthAppSection: some View {
        Section {
            Button("Fill All from Health app") {
                
            }
        }
    }
    
    var movingAverageFooter: some View {
        Text("Use a 7-day moving average of your weight data when available.\n\nThis makes the calculation less affected by cyclical fluctuations in your weight due to factors like fluid loss.")
    }
}

let MockMaintenanceSamples: [MaintenanceSample] = [
    .init(type: .healthKit, value: 96.0),
    .init(type: .healthKit, value: 101.0),
    .init(type: .userEntered, value: 96.0),
    .init(type: .averaged, value: 101.0),

    .init(type: .healthKit, value: 3460),
    .init(type: .healthKit, value: 2404),
    .init(type: .userEntered, value: 2781),
    .init(type: .averaged, value: 1853),
]

#Preview {
    Text("Health Details")
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
                MaintenanceAdaptiveForm(MockHealthModel)
                    .environment(SettingsStore.shared)
                    .onAppear {
                        SettingsStore.configureAsMock()
                    }
            }
        }
}
