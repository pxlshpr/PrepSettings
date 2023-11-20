import SwiftUI
import PrepShared

//TODO: Next
/// [x] Consider having movingAverageInterval as a property in sample itself, so user could essentially have it set for one weight and not set for the other for whatever reason?
/// [x] Add a field for numberOfAveragedValues, and have a stepper that lets user choose the interval, ranging from 2 days to 3 weeks, defaulting it 1 week
extension WeightSampleForm {
    @Observable class Model {
        
        let date: Date
        var sample: MaintenanceSample
        var type: MaintenanceSampleType
        var value: Double

        init(sample: MaintenanceSample, date: Date) {
            self.sample = sample
            self.type = sample.type
            self.value = sample.value ?? 0
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

struct WeightSampleForm: View {
    
    @State var model: Model
    
    init(sample: MaintenanceSample, date: Date) {
        _model = State(initialValue: Model(sample: sample, date: date))
    }
    
    var body: some View {
        Form {
            Section {
                typeRow
                movingAverageRows
                valueRow
            }
//            useMovingAverageSection
            movingAverageWeights
        }
        .navigationTitle(model.date.adaptiveMaintenanceDateString)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
    }
    
    var movingAverageRows: some View {
        Group {
            HStack {
                Toggle("Moving Average", isOn: model.usingMovingAverageBinding)
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

    var useMovingAverageSection: some View {
        Section(footer: movingAverageFooter) {
            HStack {
                Toggle("Use Moving Average", isOn: model.usingMovingAverageBinding)
            }
        }
    }
    
    var movingAverageWeights: some View {
        
        var footer: some View {
            Text("The average of these values is being used.")
        }
        
        func cell(_ daysAgo: Int) -> some View {
            HStack {
                Text(model.date.moveDayBy(-daysAgo).adaptiveMaintenanceDateString)
                Spacer()
                if let value = model.movingAverageValue(at: daysAgo) {
                    Text(value.cleanAmount)
                        .foregroundStyle(model.type == .healthKit ? Color(.secondaryLabel) : Color(.label))
//                    Text("kg")
//                        .foregroundStyle(.secondary)
                } else {
                    Text("Not set")
                        .foregroundStyle(.tertiary)
                }
            }
        }
        
        var header: some View {
            HStack {
                Spacer()
                Text("Kilograms")
            }
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
    
    var movingAverageFooter: some View {
        Text("Use a 7-day moving average of your weight data when available.\n\nThis makes the calculation less affected by cyclical fluctuations in your weight due to factors like fluid loss.")
    }
    
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Save") {
                
            }
            .disabled(true)
        }
    }
    
    @ViewBuilder
    var valueRow: some View {
        HStack {
            Spacer()
            switch model.type {
            case .userEntered:  manualValue
            case .healthKit:    healthValue
            case .averaged:     healthValue
            }
        }
    }
    
    var typeRow: some View {
        HStack {
            Text(MaintenanceComponent.weight.name)
            Spacer()
            MenuPicker(MaintenanceSampleType.options(for: .weight), $model.type)
        }
    }
    
    @ViewBuilder
    var manualValue: some View {
        if model.isUsingMovingAverage {
            healthValue
        } else {
            ManualHealthField(
                unitBinding: .constant(BodyMassUnit.kg),
                valueBinding: $model.value,
                firstComponentBinding: .constant(0),
                secondComponentBinding: .constant(0)
            )
        }
    }
    
    var healthValue: some View {
        CalculatedHealthView(
            quantityBinding: .constant(Quantity(value: 96.0, date: Date.now)),
            secondComponent: 0,
            unitBinding: .constant(BodyMassUnit.kg),
            source: model.type
        )
    }
}

#Preview {
    Text("")
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
                WeightSampleForm(sample: MockMaintenanceSamples[1], date: Date.now)
            }
        }
}
