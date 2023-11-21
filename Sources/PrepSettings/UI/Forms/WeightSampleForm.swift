import SwiftUI
import PrepShared

struct WeightMovingAverageComponentForm: View {
    
    init(value: Double?, date: Date) {
        //TODO: Create a Model
        /// [ ] Store the value, have a textValue too, store the initial value too
        /// [ ] Store the date
        /// [ ] Pass in the delegate (do this for WeightSampleForm.Model too
        /// [ ] Use the delegate to show confirmation before saving
        /// [ ] Have a didSave closure passed in to this and WeightSampleForm.Model too
        /// [ ] When saved, set the value in the array of moving averages and recalculate the average
        /// [ ] Now display the average value not letting user edit in WeightSampleForm
        /// [ ] Handle the unit change by simply changing what the displayed value is, but still storing it using kilograms perhaps
        /// [ ] When not in kilograms, save entered value after converting to kilograms
    }
    
    var body: some View {
        Text("Form")
    }
}

struct WeightSampleForm: View {
    
    @State var model: Model
    
    init(sample: MaintenanceWeightSample, date: Date) {
        _model = State(initialValue: Model(sample: sample, date: date))
    }
    
    var body: some View {
        Form {
            valueSection
            movingAverageSection
            movingAverageValuesSection
            removeButton
        }
        .navigationTitle(model.date.adaptiveMaintenanceDateString)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
    }
    
    @ViewBuilder
    var removeButton: some View {
        if model.value != nil {
            Section {
                Button("Remove weight") {
                    withAnimation {
                        model.value = nil
                    }
                }
            }
        }
    }
    
    var valueSection: some View {
        Section("Weight") {
            HStack {
                if model.value == nil {
                    Button("Set weight") {
                        withAnimation {
                            model.value = 0
                            model.textValue = 0
                        }
                    }
                } else {
                    if model.isUsingMovingAverage {
                        Text("Average goes here")
                    } else {
                        ManualHealthField(
                            unitBinding: .constant(BodyMassUnit.kg),
                            valueBinding: $model.textValue,
                            firstComponentBinding: .constant(0),
                            secondComponentBinding: .constant(0)
                        )
                    }
                }
//                if model.isUsingMovingAverage {
//                    Text("Average value")
//                    CalculatedHealthView(
//                        quantityBinding: .constant(Quantity(value: 96.0, date: Date.now)),
//                        secondComponent: 0,
//                        unitBinding: .constant(BodyMassUnit.kg),
//                        source: model.type
//                    )
//                } else {
//                    Text("Manual Health Field")
//                }
            }
        }
    }
    
    var movingAverageSection: some View {
        var footer: some View {
            Text("Using a moving average makes the calculation less affected by fluctuations due to factors like fluid loss.")
        }
        
        var section: some View {
            Section(footer: footer) {
                HStack {
                    Toggle("Use Moving Average", isOn: model.usingMovingAverageBinding)
                }
                if model.isUsingMovingAverage {
                    HStack {
                        Spacer()
                        Text("of the past")
                        Stepper("", value: model.movingAverageIntervalValueBinding, in: model.movingAverageIntervalPeriod.range)
                            .fixedSize()
                        Text("\(model.movingAverageIntervalValue)")
                            .font(.system(.body, design: .monospaced, weight: .bold))
                            .contentTransition(.numericText(value: Double(model.movingAverageIntervalValue)))
                            .foregroundStyle(.secondary)
                        MenuPicker<HealthPeriod>([.day, .week], model.movingAverageIntervalPeriodBinding)
                    }
                }
            }
        }
        
        return Group {
            if model.value != nil {
                section
            }
        }
    }

    var movingAverageValuesSection: some View {
        
        var footer: some View {
            Text("The average of these values is being used.")
        }
        
        func cell(_ daysAgo: Int) -> some View {
            
            var valueText: some View {
                if let value = model.movingAverageValue(at: daysAgo) {
                    Text(value.cleanAmount)
                        .foregroundStyle(Color(.secondaryLabel))
//                        .foregroundStyle(model.type == .healthKit ? Color(.secondaryLabel) : Color(.label))
//                    Text("kg")
//                        .foregroundStyle(.secondary)
                } else {
                    Text("Not set")
                        .foregroundStyle(.tertiary)
                }
            }
            
            var date: Date {
                model.date.moveDayBy(-daysAgo)
            }
            
            var dateText: some View {
                Text(date.adaptiveMaintenanceDateString)
                    .foregroundStyle(.secondary)
            }
            
            var label: some View {
                HStack {
                    valueText
                    Spacer()
                    dateText
                }
            }
            
            return NavigationLink {
                WeightMovingAverageComponentForm(value: 0, date: date)
            } label: {
                label
            }
        }
        
        var header: some View {
            Text("Kilograms")
        }
        
        return Group {
            if model.isUsingMovingAverage {
                Section(header: header, footer: footer) {
                    ForEach(0...model.movingAverageNumberOfDays-1, id: \.self) { daysAgo in
                        cell(daysAgo)
                    }
                }
            }
        }
    }
    
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Save") {
                
            }
            .disabled(true)
        }
    }
}

#Preview {
    Text("")
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
                WeightSampleForm(sample: .init(), date: Date.now)
            }
        }
}

extension WeightSampleForm {
    @Observable class Model {

        let sampleBeingEdited: MaintenanceWeightSample
        var sample: MaintenanceWeightSample

        let date: Date
        var value: Double?
        var textValue: Double

        init(sample: MaintenanceWeightSample, date: Date) {
            self.sampleBeingEdited = sample
            self.sample = sample
            self.value = sample.value
            self.textValue = sample.value ?? 0
            self.date = date
        }
    }
}

extension WeightSampleForm.Model {
    
    var movingAverageNumberOfDays: Int {
        sample.movingAverageInterval?.numberOfDays ?? DefaultNumberOfDaysForMovingAverage
    }
    
    var usingMovingAverageBinding: Binding<Bool> {
        Binding<Bool>(
            get: { self.isUsingMovingAverage },
            set: { newValue in
                withAnimation {
                    switch newValue {
                    case false:
                        self.sample.averagedValues = nil
                    case true:
                        self.sample.averagedValues = [:]
                    }
                }
            }
        )
    }
    
    var movingAverageIntervalPeriodBinding: Binding<HealthPeriod> {
        Binding<HealthPeriod>(
            get: { self.movingAverageIntervalPeriod },
            set: { newValue in
                withAnimation {
                    var value = self.movingAverageIntervalValue
                    switch newValue {
                    case .day:
                        value = max(2, value)
                    default:
                        break
                    }
                    self.sample.movingAverageInterval = .init(value, newValue)
                }
            }
        )
    }
    
    var movingAverageIntervalPeriod: HealthPeriod {
        sample.movingAverageInterval?.period ?? .week
    }
    
    var movingAverageIntervalValueBinding: Binding<Int> {
        Binding<Int>(
            get: { self.movingAverageIntervalValue },
            set: { newValue in
//                guard let interval = self.sample.movingAverageInterval else { return }
                withAnimation {
                    self.sample.movingAverageInterval = .init(newValue, self.movingAverageIntervalPeriod)
                }
            }
        )
    }

    var movingAverageIntervalValue: Int {
        sample.movingAverageInterval?.value ?? 1
    }
    
    var isUsingMovingAverage: Bool {
        sample.averagedValues != nil
    }
    
    func movingAverageValue(at index: Int) -> Double? {
        sample.averagedValues?[index]
    }
}
