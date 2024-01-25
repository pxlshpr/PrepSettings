import SwiftUI
import SwiftSugar
import PrepShared

struct FatPercentageForm: View {
    
    @Bindable var provider: Provider
    @Binding var isPresented: Bool
    
    let date: Date

    @State var percent: Double?
    @State var dailyMeasurementType: DailyMeasurementType
    @State var measurements: [FatPercentageMeasurement]
    @State var deletedHealthKitMeasurements: [FatPercentageMeasurement]
    @State var isSynced: Bool = true
    
    @State var showingForm = false
    
    let saveHandler: (HealthDetails.FatPercentage) -> ()

    init(
        date: Date,
        fatPercentage: HealthDetails.FatPercentage,
        provider: Provider,
        isPresented: Binding<Bool> = .constant(true),
        save: @escaping (HealthDetails.FatPercentage) -> ()
    ) {
        self.date = date
        self.saveHandler = save
        self.provider = provider
        _isPresented = isPresented
        
        _percent = State(initialValue: fatPercentage.fatPercentage)
        _measurements = State(initialValue: fatPercentage.measurements)
        _dailyMeasurementType = State(initialValue: provider.settings.dailyMeasurementType(for: .fatPercentage))
        _deletedHealthKitMeasurements = State(initialValue: fatPercentage.deletedHealthKitMeasurements)
        _isSynced = State(initialValue: provider.fatPercentageIsHealthKitSynced)
    }
    
    init(
        provider: Provider,
        isPresented: Binding<Bool> = .constant(true)
    ) {
        self.init(
            date: provider.healthDetails.date,
            fatPercentage: provider.healthDetails.fatPercentage,
            provider: provider,
            isPresented: isPresented,
            save: provider.saveFatPercentage
        )
    }

    var body: some View {
        Form {
            dateSection
            measurementsSections
            convertedMeasurementsSections
            dailyMeasurementTypePicker
            syncSection
            explanation
        }
        .navigationTitle("Body Fat Percentage")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { toolbarContent }
        .sheet(isPresented: $showingForm) { measurementForm }
        .safeAreaInset(edge: .bottom) { bottomValue }
        .onChange(of: isSynced, isSyncedChanged)
    }
    
    var convertedMeasurementsSections: some View {
        var header: some View {
            Text("Converted Lean Body Masses")
        }
        var footer: some View {
            Text("These measurements have been converted from your lean body mass measurements using your weight for the day.")
        }
        
        var section: some View {
            Section(header: header, footer: footer) {
                ForEach(measurements.converted, id: \.id) { measurement in
                    MeasurementCell<PercentUnit>(
                        measurement: measurement,
                        provider: provider,
                        isDisabled: true,
                        deleteAction: { }
                    )
                }
            }
        }
        
        return Group {
            if !measurements.converted.isEmpty {
                section
            }
        }
    }
    
    func isSyncedChanged(old: Bool, new: Bool) {
        provider.setHealthKitSyncing(for: .fatPercentage, to: new)
    }

    var explanation: some View {
        var header: some View {
            Text("Usage")
                .formTitleStyle()
        }
        
        return Section(header: header) {
            VStack(alignment: .leading) {
                Text("Your body fat percentage is the weight of fat in your body, compared to your total body weight, which includes muscles, bones, water and so on. It is used when calculating your Resting Energy using certain equations.")
            }
        }
    }
    
    var dateSection: some View {
        Section {
            HStack {
                Text("Date")
                Spacer()
                Text(date.shortDateString)
            }
        }
    }
    
    var bottomValue: some View {
        return MeasurementBottomBar(
            double: Binding<Double?>(
                get: { percent }, set: { _ in }
            ),
            doubleString: Binding<String?>(
                get: { percent?.cleanHealth }, set: { _ in }
            ),
            doubleUnitString: "%"
        )
    }
    
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                isPresented = false
            } label: {
                CloseButtonLabel()
            }
        }
    }
    
    var measurementForm: some View {
        FatPercentageMeasurementForm(provider: provider) { measurement in
            measurements.append(measurement)
            measurements.sort()
            handleChanges()
        }
    }
    
    var dailyMeasurementTypePicker: some View {
        let binding = Binding<DailyMeasurementType>(
            get: { dailyMeasurementType },
            set: { newValue in
                withAnimation {
                    dailyMeasurementType = newValue
                    provider.setDailyMeasurementType(
                        for: .fatPercentage,
                        to: newValue
                    )
                    handleChanges()
                }
            }
        )
        
        var pickerRow: some View {
            Picker("", selection: binding) {
                ForEach(DailyMeasurementType.allCases, id: \.self) {
                    Text($0.name).tag($0)
                }
            }
            .pickerStyle(.segmented)
            .listRowSeparator(.hidden)
        }

        var description: String {
            dailyMeasurementType.description(for: .fatPercentage)
        }

        var header: some View {
            Text("Handling Multiple Measurements")
        }

        return Section(header: header) {
            pickerRow
            Text(description)
        }
    }
    
    var syncSection: some View {
        SyncSection(
            healthDetail: .fatPercentage,
            isSynced: $isSynced,
            handleChanges: handleChanges
        )
    }
    
    var measurementsSections: some View {
        MeasurementsSections<PercentUnit>(
            provider: provider,
            measurements: Binding<[any Measurable]>(
                get: { measurements.nonConverted },
                set: { newValue in
                    guard let measurements = newValue as? [FatPercentageMeasurement] else { return }
                    self.measurements = measurements
                }
            ),
            deletedHealthKitMeasurements: Binding<[any Measurable]>(
                get: { deletedHealthKitMeasurements },
                set: { newValue in
                    guard let measurements = newValue as? [FatPercentageMeasurement] else { return }
                    self.deletedHealthKitMeasurements = measurements
                }
            ),
            showingForm: $showingForm,
            handleChanges: handleChanges
        )
    }
    
    func save() {
        saveHandler(fatPercentage)
    }
    
    func handleChanges() {
        percent = calculatedFatPercentage
        save()
    }
    
    var calculatedFatPercentage: Double? {
        measurements.dailyMeasurement(for: dailyMeasurementType)
    }

    var fatPercentage: HealthDetails.FatPercentage {
        HealthDetails.FatPercentage(
            fatPercentage: calculatedFatPercentage,
            measurements: measurements,
            deletedHealthKitMeasurements: deletedHealthKitMeasurements
        )
    }
}

struct FatPercentageFormPreview: View {
    @State var provider: Provider? = nil
    
    @ViewBuilder
    var body: some View {
        if let provider {
            NavigationView {
                FatPercentageForm(provider: provider)
            }
        } else {
            Color.clear
                .task {
                    var healthDetails = await Provider.fetchOrCreateHealthDetailsFromBackend(Date.now)
                    healthDetails.weight = .init(
                        weightInKg: 95,
                        measurements: [.init(date: Date.now, weightInKg: 95)]
                    )
                    let provider = Provider()
                    provider.healthDetails = healthDetails
                    await MainActor.run {
                        self.provider = provider
                    }
                }
        }
    }
}

#Preview("Form") {
    FatPercentageFormPreview()
}

#Preview("Demo") {
    SettingsDemoView()
}
