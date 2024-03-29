import SwiftUI
import SwiftSugar
import PrepShared

struct LeanBodyMassForm: View {
    
    @Bindable var provider: Provider
    @Binding var isPresented: Bool
    
    let date: Date

    @State var leanBodyMassInKg: Double?
    @State var dailyMeasurementType: DailyMeasurementType
    @State var measurements: [LeanBodyMassMeasurement]
    @State var deletedHealthKitMeasurements: [LeanBodyMassMeasurement]
    @State var isSynced: Bool = true
    
    @State var showingForm = false
    
    let saveHandler: (HealthDetails.LeanBodyMass) -> ()

    init(
        date: Date,
        leanBodyMass: HealthDetails.LeanBodyMass,
        provider: Provider,
        isPresented: Binding<Bool> = .constant(true),
        save: @escaping (HealthDetails.LeanBodyMass) -> ()
    ) {
        self.date = date
        self.saveHandler = save
        self.provider = provider
        _isPresented = isPresented
        
        _leanBodyMassInKg = State(initialValue: leanBodyMass.leanBodyMassInKg)
        _measurements = State(initialValue: leanBodyMass.measurements)
        _dailyMeasurementType = State(initialValue: provider.settings.dailyMeasurementType(for: .leanBodyMass))
        _deletedHealthKitMeasurements = State(initialValue: leanBodyMass.deletedHealthKitMeasurements)
        _isSynced = State(initialValue: provider.leanBodyMassIsHealthKitSynced)
    }
    
    init(
        provider: Provider,
        isPresented: Binding<Bool> = .constant(true)
    ) {
        self.init(
            date: provider.healthDetails.date,
            leanBodyMass: provider.healthDetails.leanBodyMass,
            provider: provider,
            isPresented: isPresented,
            save: provider.saveLeanBodyMass
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
        .navigationTitle("Lean Body Mass")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { toolbarContent }
        .sheet(isPresented: $showingForm) { measurementForm }
        .safeAreaInset(edge: .bottom) { bottomValue }
        .onChange(of: isSynced, isSyncedChanged)
    }
    
    var convertedMeasurementsSections: some View {
        var header: some View {
            Text("Converted Fat Percentages")
        }
        var footer: some View {
            Text("These measurements have been converted from your fat percentage measurements using your weight for the day.")
        }
        
        var section: some View {
            Section(header: header, footer: footer) {
                ForEach(measurements.converted, id: \.id) { measurement in
                    MeasurementCell<BodyMassUnit>(
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
        provider.setHealthKitSyncing(for: .leanBodyMass, to: new)
    }

    var explanation: some View {
        var header: some View {
            Text("Usage")
                .formTitleStyle()
        }
        
        return Section(header: header) {
            VStack(alignment: .leading) {
                Text("Your lean body mass is the weight of your body minus your body fat (adipose tissue). It is used when:")
                dotPoint("Creating goals. For example, you could create a protein goal relative to your lean body mass instead of your weight.")
                dotPoint("Calculating your Resting Energy using certain equations.")
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
    
    var bodyMassUnit: BodyMassUnit {
        provider.bodyMassUnit
    }
    
    var bottomValue: some View {
        var intUnitString: String? { bodyMassUnit.intUnitString }
        var doubleUnitString: String { bodyMassUnit.doubleUnitString }
        
        var double: Double? {
            guard let leanBodyMassInKg else { return nil }
            return BodyMassUnit.kg
                .doubleComponent(leanBodyMassInKg, in: bodyMassUnit)
        }
        
        var int: Int? {
            guard let leanBodyMassInKg else { return nil }
            return BodyMassUnit.kg
                .intComponent(leanBodyMassInKg, in: bodyMassUnit)
        }
        
        return MeasurementBottomBar(
            int: Binding<Int?>(
                get: { int }, set: { _ in }
            ),
            intUnitString: intUnitString,
            double: Binding<Double?>(
                get: { double }, set: { _ in }
            ),
            doubleString: Binding<String?>(
                get: { double?.cleanHealth }, set: { _ in }
            ),
            doubleUnitString: doubleUnitString
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
        LeanBodyMassMeasurementForm(provider: provider) { measurement in
            measurements.append(measurement)
            //TODO: Add a fat percentage measurement based on the latest weight – with a source of .leanBodyMass
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
                    provider.setDailyMeasurementType(for: .leanBodyMass, to: newValue)
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
            dailyMeasurementType.description(for: .leanBodyMass)
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
            healthDetail: .leanBodyMass,
            isSynced: $isSynced,
            handleChanges: handleChanges
        )
    }
    
    var measurementsSections: some View {
        MeasurementsSections<BodyMassUnit>(
            provider: provider,
            measurements: Binding<[any Measurable]>(
                get: { measurements.nonConverted },
                set: { newValue in
                    guard let measurements = newValue as? [LeanBodyMassMeasurement] else { return }
                    self.measurements = measurements
                }
            ),
            deletedHealthKitMeasurements: Binding<[any Measurable]>(
                get: { deletedHealthKitMeasurements },
                set: { newValue in
                    guard let measurements = newValue as? [LeanBodyMassMeasurement] else { return }
                    self.deletedHealthKitMeasurements = measurements
                }
            ),
            showingForm: $showingForm,
            handleChanges: handleChanges
        )
    }
    
    func save() {
        saveHandler(leanBodyMass)
    }
    
    func handleChanges() {
        leanBodyMassInKg = calculatedLeanBodyMassInKg
        save()
    }
    
    var calculatedLeanBodyMassInKg: Double? {
        measurements.dailyMeasurement(for: dailyMeasurementType)
    }
    
    var leanBodyMass: HealthDetails.LeanBodyMass {
        HealthDetails.LeanBodyMass(
            leanBodyMassInKg: calculatedLeanBodyMassInKg,
            measurements: measurements,
            deletedHealthKitMeasurements: deletedHealthKitMeasurements
        )
    }
}

struct LeanBodyMassFormPreview: View {
    @State var provider: Provider? = nil
    
    @ViewBuilder
    var body: some View {
        if let provider {
            NavigationView {
                LeanBodyMassForm(provider: provider)
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
    LeanBodyMassFormPreview()
}

#Preview("Demo") {
    SettingsDemoView()
}
