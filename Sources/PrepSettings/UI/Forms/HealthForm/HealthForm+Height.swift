import SwiftUI
import PrepShared

struct HealthHeightSection: View {
    
    @Bindable var model: HealthModel
    
    var body: some View {
        Section(header: header, footer: footer) {
            HealthSourcePicker(sourceBinding: $model.heightSource)
            valueRow
            healthKitErrorCell
        }
    }
    
    var header: some View {
        HealthHeader(type: .height)
            .environment(model)
    }
    
    var footer: some View {
        HealthFooter(
            source: model.heightSource,
            type: .height,
            hasQuantity: model.health.heightQuantity != nil
        )
    }
    
    @ViewBuilder
    var healthKitErrorCell: some View {
        if model.health.heightSource == .healthKit, model.health.height?.quantity == nil {
            HealthKitErrorCell(type: .height)
        }
    }
    
    @ViewBuilder
    var valueRow: some View {
        if let height = model.health.height {
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
}

extension HealthForm {

//    var height: HealthQuantity {
//        model.health.height ?? .init(source: .default)
//    }
    
    var heightSection: some View {
        HealthHeightSection(model: model)
//        var healthValue: some View {
//            CalculatedHealthView(
//                quantityBinding: $model.health.heightQuantity,
//                secondComponent: model.heightCentimetersComponent,
//                unitBinding: $model.healthHeightUnit,
//                source: model.heightSource
//            )
//        }
//        
//        var manualValue: some View {
//            ManualHealthField(
//                unitBinding: $model.healthHeightUnit,
//                valueBinding: $model.heightValue,
//                firstComponentBinding: $model.heightFeetComponent,
//                secondComponentBinding: $model.heightCentimetersComponent
//            )
//        }
//        
//        return Section(
//            header: Text("Height"),
//            footer: HealthFooter(
//                source: model.heightSource,
//                type: .height,
//                hasQuantity: model.health.heightQuantity != nil
//            )
//        ) {
//            HealthSourcePicker(sourceBinding: $model.heightSource)
//            HStack {
//                Spacer()
//                switch height.source {
//                case .healthKit:
//                    healthValue
//                case .userEntered:
//                    manualValue
//                }
//            }
//        }
    }
}
