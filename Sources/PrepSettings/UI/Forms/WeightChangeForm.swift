import SwiftUI
import PrepShared

struct WeightChangeForm: View {
    
    @Environment(SettingsStore.self) var settingsStore: SettingsStore
    @Bindable var healthModel: HealthModel
    @Environment(\.dismiss) var dismiss
    
    @FocusState var focusedType: HealthType?
    
    @State var textFieldValue: Double? = nil
    @State var textFieldValueString: String? = nil
    @State var isNegative = false

    init(_ healthModel: HealthModel) {
        self.healthModel = healthModel
        
        if let delta = healthModel.maintenanceWeightChangeDelta {
            _textFieldValue = State(initialValue: abs(delta))
            _textFieldValueString = State(initialValue: abs(delta).cleanWithoutRounding)
            _isNegative = State(initialValue: delta < 0)
        }
    }
    
    var body: some View {
        Form {
//            descriptionSection
            sourceSection
            weightsSections
            valueSection
        }
        .navigationTitle("Weight Change")
        .navigationBarTitleDisplayMode(.inline)
//        .onChange(of: focusedType, healthModel.focusedTypeChanged)
        .onChange(of: focusedType, focusedTypeChanged)
        .toolbar { keyboardToolbarContent }
    }
    
    var descriptionSection: some View {
        Section {
            Text("Your weight change will be used to determin")
                .font(.callout)
        }
    }
    
    func focusedTypeChanged(old: HealthType?, new: HealthType?) {
        let lostFocus = new == nil
        if lostFocus {
            setDeltaFromTextFieldValue()
        }
    }
    
    func setDeltaFromTextFieldValue() {
        if let value = textFieldValue {
            healthModel.maintenanceWeightChangeDelta = value * (isNegative ? -1 : 1)
        } else {
            healthModel.maintenanceWeightChangeDelta = nil
        }
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
            Section("Current") {
                weightCell(sample: maintenance.adaptive.weightChange.current, isPrevious: false)
            }
            Section("Previous") {
                weightCell(sample: maintenance.adaptive.weightChange.previous, isPrevious: true)
            }
        }
    }
    
    var valueSection: some View {
        
        var plusMinusButton: some View {
            
            var weightChange: WeightChange? {
                healthModel.health.maintenance?.adaptive.weightChange
            }
            var shouldShow: Bool {
                guard let weightChange,
                      weightChange.type == .userEntered,
                      let textFieldValue
                else { return false }
                
                return textFieldValue != 0
            }
            
            let binding = Binding<Bool>(
                get: { isNegative },
                set: {
                    isNegative = $0
                    setDeltaFromTextFieldValue()
                }
            )
            
            return Group {
                if shouldShow {
                    Picker("", selection: binding) {
                        Group {
                            Image(systemName: "minus").tag(true)
                            Image(systemName: "plus").tag(false)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
        }
        
        @ViewBuilder
        var valueRow: some View {
            HStack {
                plusMinusButton
                Spacer()
                switch type {
                case .usingWeights:
                    if let delta = maintenance.adaptive.weightChange.delta(in: settingsStore.bodyMassUnit) {
                        LargeHealthValue(
                            value: delta,
                            valueString: delta.clean,
                            unitString: settingsStore.bodyMassUnit.abbreviation
                        )
                    } else {
                        Text("Not Set")
                            .foregroundStyle(.secondary)
                    }
                case .userEntered:
                    textField
                }
            }
        }
        
        var textField: some View {
            
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
                valueBinding: $textFieldValue,
                valueString: $textFieldValueString,
                focusedType: $focusedType,
                healthType: .maintenance
            )
        }

        return Section {
            ZStack(alignment: .bottomTrailing) {
                valueRow
                LargePlaceholderText
            }
        }
    }
    
    var sourceSection: some View {
        
        func weightChangeTypeChanged(to type: WeightChangeType) {

            if type == .usingWeights {
                focusedType = nil
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    healthModel.health.maintenance?.adaptive.weightChange.calculateDelta()
                }
            }
            
            if type == .userEntered {
                isNegative = healthModel.maintenanceWeightChangeDeltaIsNegative
                textFieldValue = healthModel.maintenanceWeightChangeDelta?.rounded(toPlaces: 2)
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
                weightChangeTypeChanged(to: type)
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
        
        let binding = Binding<WeightChangeType>(
            get: { type },
            set: { newValue in
//                self.type = newValue
                weightChangeTypeChanged(to: newValue)
            }
        )
        
        return PickerSection(binding)
        
//        return Section {
//            ForEach(WeightChangeType.allCases, id: \.self) {
//                button(for: $0)
//            }
//        }
    }
    
    func weightCell(sample: WeightSample, isPrevious: Bool) -> some View {
        
        var date: Date { isPrevious ? previousDate : currentDate }
        
        var dateRow: some View {
            HStack {
                Text("Date")
                Spacer()
                Text(date.adaptiveMaintenanceDateString)
            }
        }
        
        var linkRow: some View {
            NavigationLink(value: WeightSampleRoute(
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
        
        return Group {
            dateRow
            linkRow
        }
    }
    
    func sampleForm(for route: WeightSampleRoute) -> some View {
        WeightForm(
            sample: route.sample,
            date: route.date,
            isPrevious: route.isPrevious,
            healthModel: healthModel,
            settingsStore: settingsStore
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

    var maintenance: HealthDetails.Maintenance {
        healthModel.health.maintenance ?? .init()
    }
}

#Preview {
    NavigationStack {
        WeightChangeForm(MockCurrentHealthModel)
//        HealthSummary(model: MockHealthModel)
            .environment(SettingsStore.shared)
            .onAppear {
                SettingsStore.configureAsMock()
            }
    }
}

var LargePlaceholderText: some View {
    LargeHealthValue(
        value: 0,
        valueString: "0",
        unitString: "kg"
    )
    .opacity(0)
}

extension String {
    var double: Double? {
        Double(self)
    }
}

#Preview {
    Text("")
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
                WeightChangeForm(MockCurrentHealthModel)
                    .environment(SettingsStore.shared)
                .onAppear {
                    SettingsStore.configureAsMock()
                }
            }
        }
}
