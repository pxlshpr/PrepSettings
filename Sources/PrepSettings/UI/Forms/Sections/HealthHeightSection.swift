import SwiftUI
import PrepShared

struct HealthHeightSection: View {
    
    @Bindable var model: HealthModel
    
    init(_ model: HealthModel) {
        self.model = model
    }
    
    var body: some View {
        Section(footer: footer) {
            HealthTopRow(type: .height, model: model)
            valueRow
            healthKitErrorCell
        }
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
        if model.shouldShowHealthKitError(for: .height) {
            HealthKitErrorCell(type: .height)
        }
    }
    
    @ViewBuilder
    var valueRow: some View {
        if let height = model.health.height {
            HStack {
                Spacer()
                if model.isSettingTypeFromHealthKit(.height) {
                    ProgressView()
                } else {
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
    
    var healthValue: some View {
        CalculatedHeightView(
            unit: $model.health.heightUnit,
            quantityInCm: $model.health.heightQuantity,
            source: model.heightSource
        )
    }

    var manualValue: some View {
        ManualHeightField(
            unit: $model.health.heightUnit,
            valueInCm: $model.heightValue
        )
    }
}
