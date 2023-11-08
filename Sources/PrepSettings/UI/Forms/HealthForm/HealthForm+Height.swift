import SwiftUI
import PrepShared

extension HealthForm {

    var height: HealthQuantity {
        model.health.height ?? .init(source: .default)
    }
    
    var heightSection: some View {

        var healthValue: some View {
            CalculatedHealthView(
                quantityBinding: $model.health.heightQuantity,
                secondComponent: model.heightCentimetersComponent,
                unitBinding: $model.healthHeightUnit,
                source: model.heightSource
            )
        }
        
        var manualValue: some View {
            ManualHealthField(
                unitBinding: $model.healthHeightUnit,
                valueBinding: $model.heightValue,
                firstComponentBinding: $model.heightFeetComponent,
                secondComponentBinding: $model.heightCentimetersComponent
            )
        }
        
        return Section(
            header: Text("Height"),
            footer: HealthFooter(
                source: model.heightSource,
                type: .height,
                hasQuantity: model.health.heightQuantity != nil
            )
        ) {
            HealthSourcePicker(sourceBinding: $model.heightSource)
            HStack {
                Spacer()
                switch height.source {
                case .healthKit:
                    healthValue
                case .userEntered:
                    manualValue
                }
            }
        }
    }
}
