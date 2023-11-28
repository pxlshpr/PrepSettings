import SwiftUI
import PrepShared

struct MaintenanceCalculationView: View {
    
    @Environment(SettingsStore.self) var settingsStore: SettingsStore

    @Bindable var healthModel: HealthModel
    
    @State var useMovingAverageForWeight = true
    @State var showingWeightConversionInfo = false

    init(_ model: HealthModel) {
        self.healthModel = model
    }
    
    var body: some View {
        list
            .navigationTitle("Adaptive Calculation")
            .navigationBarTitleDisplayMode(.inline)
//            .toolbar { toolbarContent }
//            .navigationBarBackButtonHidden(isEditing)
    }
    
    var list: some View {
        List {
            content
        }
    }
    
    @ViewBuilder
    var content: some View {
        daysSection
//        if !isEditing {
            weightSection
            dietaryEnergySection
            calculationSections
//        }
    }
    
    var maintenance: Health.MaintenanceEnergy {
        healthModel.health.maintenanceEnergy ?? .init()
    }
    
    var date: Date {
        healthModel.health.date
    }
    
    var weightSection: some View {
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
            Text("Weight")
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundStyle(Color(.label))
                .textCase(.none)
        }

        var previousDate: Date {
            maintenance.interval.startDate(with: date)
        }
        
        var samplesLink: some View {
            NavigationLink {
                WeightSamplesList()
                    .environment(settingsStore)
                    .environment(healthModel)
            } label: {
                Text("Show Data")
            }
        }
        
        return Group {
            Section(header: header, footer: footer) {
                samplesLink
                maintenance.weightChangeRow(bodyMassUnit: settingsStore.bodyMassUnit)
                maintenance.equivalentEnergyRow(energyUnit: settingsStore.energyUnit)
            }
        }
    }
    
    var daysSection: some View {
        var footer: some View {
//            EmptyView()
            Text("Period over which to calculate your maintenance energy.")
        }
        
        var header: some View {
            EmptyView()
//            Text("Calculated over")
        }
        
        return Section(header: header, footer: footer) {
            HStack {
                Text("Period")
//                Text("Number of days")
//                Text("Calculated over")
                Spacer()
//                Text("the past")
                Stepper("", value: healthModel.intervalValueBinding, in: healthModel.intervalPeriod.range)
                    .fixedSize()
                HStack(spacing: 4) {
                    Text("\(healthModel.intervalValue)")
                        .font(NumberFont)
                        .contentTransition(.numericText(value: Double(healthModel.intervalValue)))
                        .foregroundStyle(.secondary)
                    MenuPicker<HealthPeriod>([.day, .week], healthModel.intervalPeriodBinding)
                }
//                Text("7")
//                    .foregroundStyle(isEditing ? Color.accentColor : Color.primary)
            }
        }
    }
    
    var dietaryEnergySection: some View {
        
        var header: some View {
            Text("Dietary Energy")
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundStyle(Color(.label))
                .textCase(.none)
        }
        
        var footer: some View {
            Text("The energy you consumed over the 7 days leading up to this date.")
        }
        
        return Section(header: header, footer: footer) {
            NavigationLink {
                DietaryEnergySamplesList()
                    .environment(settingsStore)
                    .environment(healthModel)
            } label: {
                Text("Show Data")
            }
            HStack {
                Text("Total Dietary Energy")
                Spacer()
                if let total = maintenance.dietaryEnergy.total {
                    Text("\(total.formattedEnergy) kcal")
                        .foregroundStyle(.secondary)
                } else {
                    Text("Not enough data")
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }
    
    @ViewBuilder
    var calculationSections: some View {
//        Section(footer: Text("Total energy consumption that would have resulted in no change in weight.")) {
//            HStack {
//                Text("Total Maintenance")
//                Spacer()
//                Text("27,437 kcal")
//                    .foregroundStyle(.secondary)
//            }
//        }
//        Section(footer: Text("Daily energy consumption that would have resulted in no change in weight, ie. your maintenance.")) {
        Section(footer: Text("The energy you would have to consume daily to maintain your weight.")) {
//        Section {
            HStack {
                Text("Maintenance Energy")
                Spacer()
                if let value = maintenance.adaptiveValue {
                    Text("\(value.formattedEnergy) kcal")
                        .foregroundStyle(.secondary)
                } else {
                    Text("Not enough data")
                        .foregroundStyle(.tertiary)
                }
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
    
    //TODO: Next
    /// [x] Store data points in health (2 for weight, and 7 for dietary energy)
    /// [ ] Now write the automatic healthkit fetching code that grabs the values from HealthKit
    /// [ ] Now test the maintenance thing for a date in the past where we have health kit data
    /// [ ] Feed in data points that are stored in health here in the cell
    /// [ ] Let values be nil and if nil, show "Not set" in list itself
    /// [ ] Now complete the form, with bindings for picker and value
    /// [ ] Make sure the data is only saved when the user actually taps on "Save" (simply going back shouldn't save it\
    /// [ ] Add the field in HealthSummary for date (when not today) – but first try showing today as well
    func cell(daysAgo: Int, component: MaintenanceComponent) -> some View {
        var sample: MaintenanceSample {
            .init(type: .userEntered, value: 0)
        }
        return NavigationLink {
            AdaptiveDataForm(sample, component, Date.now)
        } label: {
            AdaptiveDataCell(sample, Date.now)
        }
    }

//    @State var isEditing = false
//    
//    var toolbarContent: some ToolbarContent {
//        Group {
//            ToolbarItem(placement: .topBarTrailing) {
//                Button(isEditing ? "Done" : "Edit") {
//                    withAnimation {
//                        isEditing.toggle()
//                    }
//                }
//                .fontWeight(isEditing ? .semibold : .regular)
//            }
//            if isEditing {
//                ToolbarItem(placement: .topBarLeading) {
//                    Button("Cancel") {
//                        isEditing = false
//                    }
//                }
//            }
//        }
//    }
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
//                NavigationLink {
                MaintenanceCalculationView(MockHealthModel)
                    .environment(SettingsStore.shared)
                    .onAppear {
                        SettingsStore.configureAsMock()
                    }
//                } label: {
//                    Text("Show Data")
//                }
            }
        }
        
//        HealthSummary(model: MockHealthModel)
//        List {
//            ForEach(MockDataPoints, id: \.self) { sample in
//                NavigationLink {
//                    AdaptiveDataForm(sample, .dietaryEnergy, Date.now)
//                } label: {
//                    AdaptiveDataCell(sample, Date.now)
//                }
//            }
//        }
}
