import SwiftUI
import PrepShared

struct AdaptiveDataForm: View {
    
    @State var model: Model
    
    @Observable class Model {
        
        let date: Date
        let dataPoint: AdaptiveDataPoint
        var type: AdaptiveDataType
        var component: AdaptiveDataComponent
        var value: Double

        init(_ dataPoint: AdaptiveDataPoint, _ component: AdaptiveDataComponent, _ date: Date) {
            self.dataPoint = dataPoint
            self.type = dataPoint.type
            self.component = component
            self.value = dataPoint.value
            self.date = date
        }
    }
    
    init(_ dataPoint: AdaptiveDataPoint, _ component: AdaptiveDataComponent, _ date: Date) {
        _model = State(initialValue: Model(dataPoint, component, date))
    }
    
    var body: some View {
        Form {
            Section {
                typeRow
                valueRow
            }
        }
        .navigationTitle(model.date.adaptiveMaintenanceDateString)
        .toolbar { toolbarContent }
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
            Text(model.component.name)
            Spacer()
            MenuPicker($model.type)
        }
    }
    
    var manualValue: some View {
        ManualHealthField(
            unitBinding: .constant(BodyMassUnit.kg),
            valueBinding: $model.value,
            firstComponentBinding: .constant(0),
            secondComponentBinding: .constant(0)
        )
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
    NavigationStack {
        AdaptiveDataForm(MockDataPoints[1], .dietaryEnergy, Date.now)
    }
}
