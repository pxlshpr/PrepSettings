import SwiftUI
import PrepShared

struct HealthWeightSection: View {
    
    @Bindable var model: HealthModel
    
    init(_ model: HealthModel) {
        self.model = model
    }
    
    var body: some View {
        Section(header: header, footer: footer) {
//            HealthSourcePicker(sourceBinding: $model.weightSource)
            HealthTopRow(type: .weight, model: model)
            valueRow
            healthKitErrorCell
        }
    }
    
    var header: some View {
//        HealthHeader(type: .weight)
//            .environment(model)
        Text("Body Profile")
            .font(.title2)
            .textCase(.none)
            .foregroundStyle(Color(.label))
            .fontWeight(.bold)
            .padding(.top)
    }
    
    var footer: some View {
        HealthFooter(
            source: model.weightSource,
            type: .weight,
            hasQuantity: model.health.weightQuantity != nil
        )
    }
    
    @ViewBuilder
    var healthKitErrorCell: some View {
        if model.health.weightSource == .healthKit, model.health.weight?.quantity == nil {
            HealthKitErrorCell(type: .weight)
        }
    }
    
    @ViewBuilder
    var valueRow: some View {
        if let weight = model.health.weight {
            HStack {
                Spacer()
                switch weight.source {
                case .healthKit:
                    healthValue
                case .userEntered:
                    manualValue
                }
            }
        }
    }
    
    var healthValue: some View {
        CalculatedHealthView(
            quantityBinding: $model.health.weightQuantity,
            secondComponent: model.weightPoundsComponent,
            unitBinding: $model.healthWeightUnit,
            source: model.weightSource
        )
    }

    var manualValue: some View {
        ManualHealthField(
            unitBinding: $model.healthWeightUnit,
            valueBinding: $model.weightValue,
            firstComponentBinding: $model.weightStonesComponent,
            secondComponentBinding: $model.weightPoundsComponent
        )
    }
}
