import SwiftUI
import PrepShared

struct WeightChangeForm: View {
    
    @Environment(SettingsStore.self) var settingsStore: SettingsStore
    @Bindable var healthModel: HealthModel
    @Environment(\.dismiss) var dismiss
    
    @FocusState var focusedType: HealthType?
    @State var deltaType: DeltaType

    init(_ healthModel: HealthModel) {
        self.healthModel = healthModel
        _deltaType = State(initialValue: healthModel.maintenanceWeightChangeDeltaType)
    }
    
    var body: some View {
        Form {
            sourceSection
            weightsSections
            valueSection
        }
        .navigationTitle("Weight Change")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: focusedType, healthModel.focusedTypeChanged)
        .toolbar { keyboardToolbarContent }
    }
    
    var keyboardToolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            HStack {
                Spacer()
                Button("Done") {
                    focusedType = nil
                }
                .fontWeight(.semibold)
            }
        }
    }

    var type: WeightChangeType {
        healthModel.maintenanceWeightChangeType
    }
    
    @ViewBuilder
    var weightsSections: some View {
        if type == .usingWeights {
            Section("Previous") {
                weightCell(sample: maintenance.adaptive.weightChange.previous, isPrevious: true)
            }
            Section("Current") {
                weightCell(sample: maintenance.adaptive.weightChange.current, isPrevious: false)
            }
        }
    }
    
    var valueSection: some View {
        
        /// [ ] "No change" option broken
        @ViewBuilder
        var valueRow: some View {
            HStack {
//                Text(healthModel.health.dateRangeForMaintenanceCalculation.string)
//                    .layoutPriority(1)
                Spacer()
                switch type {
                case .usingWeights:
                    if let delta = maintenance.adaptive.weightChange.delta(in: settingsStore.bodyMassUnit) {
                        LargeHealthValue(
                            value: delta,
                            valueString: delta.clean,
                            unitString: settingsStore.bodyMassUnit.abbreviation
                        )
                    }
//                    maintenance.adaptive.weightChangeValueText(bodyMassUnit: settingsStore.bodyMassUnit)
                case .userEntered:
                    textField
                }
            }
        }
        
        var textField: some View {
            let valueBinding = Binding<Double?>(
                get: { 
                    guard let delta else { return nil }
                    return switch deltaType {
                    case .negative:  abs(delta) * -1
                    default:         abs(delta)
                    }
                },
                set: { newValue in
                    guard let newValue, newValue != 0 else {
                        delta = 0
                        deltaType = .zero
                        return
                    }
                    if deltaType == .zero {
                        deltaType = newValue > 0 ? .positive : .negative
                    }
                    delta = switch deltaType {
                    case .negative: abs(newValue) * -1
                    default:        abs(newValue)
                    }
                }
            )
            let unitBinding = Binding<BodyMassUnit>(
                get: { settingsStore.bodyMassUnit },
                set: { newValue in
                    withAnimation {
                        settingsStore.bodyMassUnit = newValue
                    }
                }
            )
            
            return HealthNumberField(
                unitBinding: unitBinding,
                valueBinding: valueBinding,
                focusedType: $focusedType,
                healthType: .maintenance
            )
        }
        
//        var footer: some View {
//            var string: String {
//                switch type {
//                case .usingWeights:
//                    "Your weight change is being calculated by using your current and previous weights."
//                case .userEntered:
//                    "Your are a using a custom entered weight change."
//                }
//            }
//            return Text(string)
//        }
        
        var delta: Double? {
            get {
                healthModel.maintenanceWeightChangeDelta
            }
            set {
                healthModel.maintenanceWeightChangeDelta = newValue
            }
        }
        
        var deltaTypeRow: some View {
            let binding = Binding<DeltaType>(
                get: { deltaType },
                set: { newValue in
                    
                    deltaType = newValue
                    
                    var delta = healthModel.maintenanceWeightChangeDelta ?? 0
                    /// If we've changed to a non-zero delta and the value is 0—change it to 1
                    if delta == 0, newValue != .zero {
                        delta = 1
                    }
                    
                    healthModel.maintenanceWeightChangeDelta = switch newValue {
                    case .negative: abs(delta) * -1
                    case .positive: abs(delta)
                    case .zero:     0
                    }
                }
            )
            return HStack {
                Picker("", selection: binding) {
                    ForEach(DeltaType.allCases, id: \.self) {
                        Text($0.nameForWeight).tag($0)
                            .disabled(true)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        
        return Section {
            if type == .userEntered {
                deltaTypeRow
            }
            valueRow
        }
    }
    
    var sourceSection: some View {
        
        func selectedWeightChangeType(_ type: WeightChangeType) {
            if type == .usingWeights {
                focusedType = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    healthModel.health.maintenance?.adaptive.weightChange.calculateDelta()
                }
            }
            
            if type == .userEntered {
                deltaType = healthModel.maintenanceWeightChangeDeltaType
            }
            withAnimation {
                healthModel.maintenanceWeightChangeType = type
            }
            
            if type == .userEntered {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    /// Set focus to text field after a delay if we select "custom"
                    focusedType = .maintenance
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        sendSelectAllTextAction()
                    }
                }
            }
        }
        
        func button(for type: WeightChangeType) -> some View {
            var isSelected: Bool {
                self.type == type
            }
            return Button {
                selectedWeightChangeType(type)
            } label: {
                HStack {
                    Image(systemName: "checkmark")
                        .opacity(isSelected ? 1 : 0)
                    Text(type.name)
                        .foregroundStyle(Color(.label))
                    Spacer()
                }
            }
        }
        
        return Section {
            ForEach(WeightChangeType.allCases, id: \.self) {
                button(for: $0)
            }
        }
    }
    
    func weightCell(sample: WeightSample, isPrevious: Bool) -> some View {
        
        var date: Date { isPrevious ? previousDate : currentDate }
        
        return NavigationLink(value: WeightSampleRoute(
            sample: sample,
            date: date,
            isPrevious: isPrevious)
        ) {
            WeightSampleCell(sample: sample, date: date)
                .environment(settingsStore)
        }
        .navigationDestination(for: WeightSampleRoute.self) { route in
            sampleForm(for: route)
        }
    }
    
    func sampleForm(for route: WeightSampleRoute) -> some View {
        func didSaveWeight(_ sample: WeightSample) {
            healthModel.setWeightSample(sample, isPrevious: route.isPrevious)
        }
        
        return WeightSampleForm(
            sample: route.sample,
            date: route.date,
            healthModel: healthModel,
            settingsStore: settingsStore,
            didSave: didSaveWeight
        )        
    }
    
    struct WeightSampleRoute: Hashable {
        let sample: WeightSample
        let date: Date
        let isPrevious: Bool
    }
    
    var currentDate: Date {
        healthModel.health.date
    }
    
    var previousDate: Date {
        maintenance.adaptive.interval.startDate(with: currentDate)
    }

    var maintenance: Health.Maintenance {
        healthModel.health.maintenance ?? .init()
    }
}

#Preview {
    NavigationStack {
        WeightChangeForm(MockHealthModel)
            .environment(SettingsStore.shared)
            .onAppear {
                SettingsStore.configureAsMock()
            }
    }
}

extension String {
    var double: Double? {
        Double(self)
    }
}
