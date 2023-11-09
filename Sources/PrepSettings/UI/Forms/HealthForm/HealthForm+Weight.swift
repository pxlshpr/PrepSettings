import SwiftUI
import PrepShared

struct HealthWeightSection: View {
    
    @Bindable var model: HealthModel
    
    var body: some View {
        Section(header: header, footer: footer) {
            HealthSourcePicker(sourceBinding: $model.weightSource)
            valueRow
            healthKitErrorCell
        }
    }
    
    var header: some View {
        HealthHeader(type: .weight)
            .environment(model)
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

extension HealthForm {

//    var weight: HealthQuantity {
//        model.health.weight ?? .init(source: .default)
//    }
    
    var weightSection: some View {
        HealthWeightSection(model: model)
//        var healthValue: some View {
//            CalculatedHealthView(
//                quantityBinding: $model.health.weightQuantity,
//                secondComponent: model.weightPoundsComponent,
//                unitBinding: $model.healthWeightUnit,
//                source: model.weightSource
//            )
//        }
//
//        var manualValue: some View {
//            ManualHealthField(
//                unitBinding: $model.healthWeightUnit,
//                valueBinding: $model.weightValue,
//                firstComponentBinding: $model.weightStonesComponent,
//                secondComponentBinding: $model.weightPoundsComponent
//            )
//        }
//        
//        return Section(
//            header: Text("Weight"),
//            footer: HealthFooter(
//                source: model.weightSource,
//                type: .weight,
//                hasQuantity: model.health.weightQuantity != nil
//            )
//        ) {
//            HealthSourcePicker(sourceBinding: $model.weightSource)
//            HStack {
//                Spacer()
//                switch weight.source {
//                case .healthKit:
//                    healthValue
//                case .userEntered:
//                    manualValue
//                }
//            }
//        }
    }
}
