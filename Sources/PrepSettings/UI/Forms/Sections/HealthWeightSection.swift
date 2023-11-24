import SwiftUI
import PrepShared

struct HealthWeightSection: View {
    
    @Bindable var model: HealthModel
    
    init(_ model: HealthModel) {
        self.model = model
    }
    
    var body: some View {
        Section(footer: footer) {
            HealthTopRow(type: .weight, model: model)
            valueRow
            healthKitErrorCell
        }
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
        if model.shouldShowHealthKitError(for: .weight) {
            HealthKitErrorCell(type: .weight)
        }
    }
    
    @ViewBuilder
    var valueRow: some View {
        if let weight = model.health.weight {
            HStack {
                Spacer()
                if model.isSettingTypeFromHealthKit(.weight) {
                    ProgressView()
                } else {
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

    var healthValue: some View {
        CalculatedBodyMassView(
            unit: $model.health.bodyMassUnit,
            quantityInKg: $model.health.weightQuantity,
            source: model.weightSource
        )
    }
     
    var manualValue: some View {
        ManualBodyMassField(
            unit: $model.health.bodyMassUnit,
            valueInKg: $model.weightValue
        )
    }
}

#Preview {
    NavigationStack {
        Form {
            HealthWeightSection(MockHealthModel)
        }
    }
}
