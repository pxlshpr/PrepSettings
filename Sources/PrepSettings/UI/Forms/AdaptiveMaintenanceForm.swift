import SwiftUI
import PrepShared

struct AdaptiveMaintenanceForm: View {
    
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
            intervalSection
            weightChangeSection
            dietaryEnergySection
//            paramsSection
            errorSection
            valueSection
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

    var intervalSection: some View {
        let binding = Binding<HealthInterval>(
            get: { healthModel.health.maintenance?.adaptive.interval ?? .init(1, .week) },
            set: {
                healthModel.health.maintenance?.adaptive.interval = $0
            }
        )
        return IntervalPicker(
            interval: binding,
            periods: [.day, .week],
            ranges: [
                .day: 3...6
            ],
            title: "Calculated Over"
        )
    }
    
//    var intervalSection_: some View {
//        
//        var stepper: some View {
//            Stepper(
//                "",
//                value: healthModel.intervalValueBinding,
//                in: healthModel.intervalPeriod.range
//            )
//            .fixedSize()
//        }
//        
//        var value: some View {
//            Text("\(healthModel.intervalValueBinding.wrappedValue)")
//                .font(NumberFont)
//                .contentTransition(.numericText(value: Double(healthModel.intervalValueBinding.wrappedValue)))
//        }
//        
//        return Section("Calculate Over") {
//            HStack {
//                stepper
//                Spacer()
//                value
//            }
//            PickerSection([.day, .week], healthModel.intervalPeriodBinding)
//        }
//    }
    
    var intervalString: String {
        "\(healthModel.intervalValue) \(healthModel.intervalPeriod.name.lowercased())\(healthModel.intervalValue > 1 ? "s" : "")"
    }
    
    var weightChangeSection: some View {
        var footer: some View {
            Text("The change in your weight over the past \(intervalString).")
        }
        
        var bodyMassUnit: BodyMassUnit {
            settingsStore.bodyMassUnit
        }
        
        var delta: Double? {
            healthModel.health.maintenance?.adaptive.weightChange.delta(in: bodyMassUnit)
        }
        
        @ViewBuilder
        var value: some View {
            if let delta {
                HStack(alignment: .firstTextBaseline, spacing: UnitSpacing) {
                    Text("\(delta > 0 ? "+" : "")\(delta.cleanAmount)")
                        .font(NumberFont)
                        .contentTransition(.numericText(value: Double(delta)))
                    Text(bodyMassUnit.abbreviation)
                }
            } else {
                Text("Not Set")
                    .foregroundStyle(.secondary)
            }
        }
        
        return Section(footer: footer) {
            NavigationLink(value: Route.weightSamples) {
                HStack {
                    Text("Weight Change")
                    Spacer()
                    value
                }
            }
        }
    }
    
    var dietaryEnergySection: some View {
        var footer: some View {
            Text("The total dietary energy that was consumed over the past \(intervalString).")
        }
        return Section(footer: footer) {
            NavigationLink(value: Route.dietaryEnergySamples) {
                HStack {
                    Text("Dietary Energy")
                    Spacer()
                    if let total = maintenance.adaptive.dietaryEnergy.total {
                        Text("\(total.formattedEnergy) kcal")
                    } else {
                        Text("Not Set")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    var errorSection: some View {
        if let error = maintenance.adaptive.error {
            MaintenanceAdaptiveErrorCell(error)
        }
    }
    
    var valueSection: some View {
        var footer: some View {
//            Text("The energy needed to maintain your current weight. Consume less or more than this to lose or gain weight.")
            Text("An accurate calculation of your true maintenance.")
        }
        
        return Group {
            if let value = maintenance.adaptive.value {
                Section(footer: footer) {
                    LargeHealthValue(
                        value: value,
                        valueString: value.formattedEnergy,
                        unitString: "\(settingsStore.energyUnit.abbreviation) / day"
                    )
                }
            }
        }
    }
    
    var maintenance: HealthDetails.Maintenance {
        healthModel.health.maintenance ?? .init()
    }
    
    var date: Date {
        healthModel.health.date
    }

    enum Route {
        case weightSamples
        case dietaryEnergySamples
    }
    
    //MARK: - Legacy

//    var daysSection: some View {
//        var footer: some View {
//            Text("The period over which to compare your weight change against your consumed dietary energy.")
//        }
//        
//        return Section(footer: footer) {
//            periodRow
//        }
//    }
//
//    var weightSection: some View {
//        Section {
//            weightChangeRow
//        }
//    }
//    
//    var dietaryEnergySection: some View {
//        Section {
//            dietaryEnergyRow
//        }
//    }
//
//    var dietaryEnergySection_: some View {
//        
//        var header: some View {
//            Text("Dietary Energy")
//                .font(.system(.title3, design: .rounded, weight: .bold))
//                .foregroundStyle(Color(.label))
//                .textCase(.none)
//        }
//        
//        var footer: some View {
//            Text("The energy you consumed over the 7 days leading up to this date.")
//        }
//        
//        var samplesLink: some View {
//            NavigationLink(value: Route.dietaryEnergySamples) {
//                Text("Show Data")
//            }
//        }
//        
//        var totalRow: some View {
//            HStack {
//                Text("Total Consumed")
//                Spacer()
//                if let total = maintenance.adaptive.dietaryEnergy.total {
//                    Text("\(total.formattedEnergy) kcal")
//                        .foregroundStyle(.secondary)
//                } else {
//                    Text("Not enough data")
//                        .foregroundStyle(.tertiary)
//                }
//            }
//        }
//        
////        return Section(header: header, footer: footer) {
//        return Section(header: header) {
//            totalRow
//            samplesLink
//        }
//    }
//    
//    var weightSection_: some View {
//        var footer: some View {
//            VStack(alignment: .leading, spacing: 5) {
//                Text("Change in your weight over the prior 7 days, converted to energy.")
//                Button("Learn More") {
//                    showingWeightConversionInfo = true
//                }
//                .font(.footnote)
//            }
//            .sheet(isPresented: $showingWeightConversionInfo) {
//                NavigationStack {
//                    Form {
//                        Text("The conversion is done using the old research that 1 lb of body fat equals 3500 kcal.")
//                        Text("This is no longer considered accurate, and you usually lose a mix of fat, lean tissue and water.")
//                        Text("We are still using this value as it's the best estimation we have to be able to make a calculation.")
//                        Text("If you consume a certain amount based on that calculation, and your weight change isn't what you desire it to be—you could keep amending the deficit or surplus until your desired weight change is achieved.")
//                        Text("Other factors like inaccuracies in logging your food could also contribute to a less accurate calculation—which is why having this calculation periodically adapt to your observed weight change is more useful than getting it precisely correct.")
//                        Text("Also, as your weight change plateaus, this conversion would be even less relevant since the energy change would be 0 regardless.")
//                    }
//                    .font(.callout)
//                    .navigationTitle("Weight to Energy Conversion")
//                    .navigationBarTitleDisplayMode(.inline)
//                    .toolbar {
//                        ToolbarItem(placement: .topBarTrailing) {
//                            Button("Done") {
//                                showingWeightConversionInfo = false
//                            }
//                            .fontWeight(.semibold)
//                        }
//                    }
//                }
//                .presentationDetents([.medium, .large])
//            }
//        }
//        
//        var header: some View {
//            Text("Weight Change")
//                .font(.system(.title3, design: .rounded, weight: .bold))
//                .foregroundStyle(Color(.label))
//                .textCase(.none)
//        }
//
//        var previousDate: Date {
//            maintenance.adaptive.interval.startDate(with: date)
//        }
//        
//        var samplesLink: some View {
//            NavigationLink(value: Route.weightSamples) {
//                Text("Show Data")
//            }
//        }
//        
//        return Group {
////            Section(header: header, footer: footer) {
//            Section(header: header) {
//                maintenance.adaptive.weightChangeRow(bodyMassUnit: settingsStore.bodyMassUnit)
//                maintenance.adaptive.equivalentEnergyRow(energyUnit: settingsStore.energyUnit)
//                samplesLink
//            }
//        }
//    }
//    
//    
//    var fetchFromHealthKitSection: some View {
//        Section {
//            Button("Fetch Available Data") {
//                Task {
//                    try await healthModel.calculateAdaptiveMaintenance()
//                }
//            }
//        }
//    }
//    
//    
//    var fillAllFromHealthAppSection: some View {
//        Section {
//            Button("Fill All from Health app") {
//                
//            }
//        }
//    }
//    
//    var movingAverageFooter: some View {
//        Text("Use a 7-day moving average of your weight data when available.\n\nThis makes the calculation less affected by cyclical fluctuations in your weight due to factors like fluid loss.")
//    }
}

//let MockMaintenanceSamples: [MaintenanceSample] = [
//    .init(type: .healthKit, value: 96.0),
//    .init(type: .healthKit, value: 101.0),
//    .init(type: .userEntered, value: 96.0),
//    .init(type: .averaged, value: 101.0),
//
//    .init(type: .healthKit, value: 3460),
//    .init(type: .healthKit, value: 2404),
//    .init(type: .userEntered, value: 2781),
//    .init(type: .averaged, value: 1853),
//]

#Preview {
    Text("Health Details")
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
//                AdaptiveMaintenanceForm(MockHealthModel)
//                    .environment(SettingsStore.shared)
//                    .onAppear {
//                        SettingsStore.configureAsMock()
//                    }
                HealthSummary(model: MockCurrentHealthModel)
                    .environment(SettingsStore.shared)
            }
        }
}
