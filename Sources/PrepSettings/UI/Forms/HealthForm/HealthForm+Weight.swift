import SwiftUI
import PrepShared

extension HealthForm {

    var weight: HealthQuantity {
        model.health.weight ?? .init(source: .default)
    }
    
    var weightSection: some View {
        
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
        
        return Section(
            header: Text("Weight"),
            footer: HealthFooter(
                source: model.weightSource,
                type: .weight,
                hasQuantity: model.health.weightQuantity != nil
            )
        ) {
            HealthSourcePicker(sourceBinding: $model.weightSource)
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
}
