import SwiftUI
import PrepShared

//TODO: Next
/// [ ] Consider having movingAverageInterval as a property in sample itself, so user could essentially have it set for one weight and not set for the other for whatever reason?
/// [ ] Add a field for numberOfAveragedValues, and have a stepper that lets user choose the interval, ranging from 2 days to 3 weeks, defaulting it 1 week
extension WeightSampleForm {
    @Observable class Model {
        
        let date: Date
        var sample: MaintenanceSample
        var type: AdaptiveDataType
        var value: Double

        init(sample: MaintenanceSample, date: Date) {
            self.sample = sample
            self.type = sample.type
            self.value = sample.value
            self.date = date
        }
    }
}

extension WeightSampleForm.Model {
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
    
    var isUsingMovingAverage: Bool {
        sample.averagedValues != nil
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
                movingAverageRow
                valueRow
            }
//            useMovingAverageSection
            movingAverageWeights
        }
        .navigationTitle(model.date.adaptiveMaintenanceDateString)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
    }
    
    var movingAverageRow: some View {
        HStack {
            Toggle("Moving Average", isOn: model.usingMovingAverageBinding)
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
        
        return Group {
            if model.isUsingMovingAverage {
                Section(footer: footer) {
                    ForEach(0...6, id: \.self) { i in
                        HStack {
                            Text(Date.now.moveDayBy(-i).adaptiveMaintenanceDateString)
                            Spacer()
                            Text("96")
                                .foregroundStyle(model.type == .healthKit ? Color(.secondaryLabel) : Color(.label))
                            Text("kg")
                                .foregroundStyle(.secondary)
                        }
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
            Text(AdaptiveDataComponent.weight.name)
            Spacer()
            MenuPicker(AdaptiveDataType.options(for: .weight), $model.type)
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
