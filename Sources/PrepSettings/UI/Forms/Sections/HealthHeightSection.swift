import SwiftUI
import PrepShared

struct HealthHeightSection: View {
    
    @Bindable var model: HealthModel
    
    init(_ model: HealthModel) {
        self.model = model
    }
    
    var body: some View {
        Section(footer: footer) {
//            HealthSourcePicker(sourceBinding: $model.heightSource)
            HealthTopRow(type: .height, model: model)
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
