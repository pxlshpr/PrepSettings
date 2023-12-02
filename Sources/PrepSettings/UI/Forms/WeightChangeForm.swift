import SwiftUI
import PrepShared

struct WeightChangeForm: View {
    
    @Environment(SettingsStore.self) var settingsStore: SettingsStore
    @Environment(HealthModel.self) var healthModel: HealthModel
    @Environment(\.dismiss) var dismiss
    
    @State var isFocused: Bool = false
    @State var isNegative = false
    
    var body: some View {
        Form {
            weightChangeSection
            sourceSection
            weightsSections
        }
        .navigationTitle("Weight Change")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var type: WeightChangeType {
        healthModel.maintenanceWeightChangeType
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
        
        @ViewBuilder
        var valueRow: some View {
            HStack {
                Text(healthModel.health.dateRangeForMaintenanceCalculation.string)
                    .layoutPriority(1)
                Spacer()
                switch type {
                case .usingWeights:
                    maintenance.weightChangeValueText(bodyMassUnit: settingsStore.bodyMassUnit)
                case .userEntered:
                    textField
                }
            }
        }
        
        var textField: some View {
            let valueBinding = Binding<Double?>(
                get: { 
                    guard let delta else { return nil }
                    return switch isNegative {
                    case true:  abs(delta) * -1
                    case false: abs(delta)
                    }
                },
                set: { newValue in
                    guard let newValue else {
                        delta = nil
                        return
                    }
                    delta = switch isNegative {
                    case true:  abs(newValue) * -1
                    case false: abs(newValue)
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
//            return ManualHealthField(
            return HealthTextField(
                unitBinding: unitBinding,
                valueBinding: valueBinding,
                isFocusedBinding: $isFocused
            )
        }
        
//        var textField2: some View {
//            let textBinding = Binding<String>(
//                get: { delta?.cleanAmount ?? "" },
//                set: { delta = $0.double }
//            )
//            
//            return HStack {
//                TextField("", text: textBinding)
//                    .keyboardType(.numberPad)
//                    .multilineTextAlignment(.trailing)
//                    .simultaneousGesture(textSelectionTapGesture)
//                    .focused($isFocused)
//                    .toolbar {
//                        ToolbarItemGroup(placement: .keyboard) {
//                            HStack {
//                                Spacer()
//                                Button("Done") {
//                                    isFocused = false
//                                }
//                                .fontWeight(.semibold)
//                            }
//                        }
//                    }
//                Text(settingsStore.bodyMassUnit.abbreviation)
//                    .foregroundStyle(.secondary)
//            }
//        }
        
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
        
        var delta: Double? {
            get {
                healthModel.maintenanceWeightChangeDelta
            }
            set {
                healthModel.maintenanceWeightChangeDelta = newValue
            }
        }
        
        var isNegativeRow: some View {
            let binding = Binding<Bool>(
                get: {
                    isNegative
//                    healthModel.maintenanceWeightChangeDeltaIsNegative
                },
                set: { newValue in
                    
                    isNegative = newValue
                    
                    guard let delta = healthModel.maintenanceWeightChangeDelta,
                          delta != 0
                    else { return }
                    
                    healthModel.maintenanceWeightChangeDelta = switch newValue {
                    case true:  abs(delta) * -1
                    case false: abs(delta)
                    }
                }
            )
            return HStack {
                Picker("", selection: binding) {
                    Text("Loss").tag(true)
                    Text("Gain").tag(false)
                }
                .pickerStyle(.segmented)
            }
        }
        
        return Section(footer: footer) {
            valueRow
            if type == .userEntered {
                isNegativeRow
            }
        }
    }
    
    var sourceSection: some View {
//        let selection = Binding<WeightChangeType>(
//            get: { type },
//            set: { newValue in
//                withAnimation {
//                    type = newValue
//                }
//            }
//        )
//
//        return Picker("Source", selection: selection) {
//            ForEach(WeightChangeType.allCases, id: \.self) {
//                Text($0.name)
//            }
//        }
//        .pickerStyle(.inline)
        
        func button(for type: WeightChangeType) -> some View {
            var isSelected: Bool {
                self.type == type
            }
            return Button {
                withAnimation {
                    healthModel.maintenanceWeightChangeType = type
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isFocused = switch type {
                    case .userEntered:  true
                    case .usingWeights: false
                    }
                    if type == .userEntered {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            sendSelectAllTextAction()
                        }
                    }
                }
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
        maintenance.interval.startDate(with: currentDate)
    }

    var maintenance: Health.MaintenanceEnergy {
        healthModel.health.maintenanceEnergy ?? .init()
    }
}

struct HealthFieldTest: View {
    @State var value: Double = 0
    var body: some View {
        NavigationStack {
            Form {
                ManualHealthField(
                    unitBinding: .constant(EnergyUnit.kcal),
                    valueBinding: $value
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        WeightChangeForm()
            .environment(SettingsStore.shared)
            .environment(MockHealthModel)
            .onAppear {
                SettingsStore.configureAsMock()
            }
        
//        HealthFieldTest()
    }
}

extension String {
    var double: Double? {
        Double(self)
    }
}
