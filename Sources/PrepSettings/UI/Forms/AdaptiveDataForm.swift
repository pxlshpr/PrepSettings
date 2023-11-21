import SwiftUI
import PrepShared

struct AdaptiveDataForm: View {
    
    @State var model: Model
    
    @Observable class Model {
        
        let date: Date
        let sample: MaintenanceSample
        var type: MaintenanceSampleType
        var component: MaintenanceComponent
        var value: Double

        init(_ sample: MaintenanceSample, _ component: MaintenanceComponent, _ date: Date) {
            self.sample = sample
            self.type = sample.type
            self.component = component
            self.value = sample.value ?? 0
            self.date = date
        }
    }
    
    init(_ sample: MaintenanceSample, _ component: MaintenanceComponent, _ date: Date) {
        _model = State(initialValue: Model(sample, component, date))
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
    
    @State var useMovingAverageForWeight: Bool = true

    @ViewBuilder
    var movingAverageRow: some View {
        if model.component == .weight {
            HStack {
                Toggle("Moving Average", isOn: $useMovingAverageForWeight)
            }
        }
    }

    @ViewBuilder
    var useMovingAverageSection: some View {
        if model.component == .weight {
            Section(footer: movingAverageFooter) {
                HStack {
                    Toggle("Use Moving Average", isOn: $useMovingAverageForWeight)
                }
            }
        }
    }
    
    var movingAverageWeights: some View {
        
        var footer: some View {
            Text("The average of these values is being used.")
        }
        
        return Group {
            if model.component == .weight, useMovingAverageForWeight {
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
            case .backend:      healthValue
            }
        }
    }
    
    var typeRow: some View {
        HStack {
            Text(model.component.name)
            Spacer()
            MenuPicker(MaintenanceSampleType.options(for: model.component), $model.type)
        }
    }
    
    @ViewBuilder
    var manualValue: some View {
        if model.component == .weight, useMovingAverageForWeight {
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
                AdaptiveDataForm(MockMaintenanceSamples[1], .weight, Date.now)
            }
        }
}
