import SwiftUI
import PrepShared

struct HealthWeightSections: View {
    
    @Bindable var settingsStore: SettingsStore
    @Bindable var model: HealthModel
    var focusedType: FocusState<HealthType?>.Binding
    
    init(
        _ model: HealthModel,
        _ settingsStore: SettingsStore,
        _ focusedType: FocusState<HealthType?>.Binding
    ) {
        self.model = model
        self.settingsStore = settingsStore
        self.focusedType = focusedType
    }

    var body: some View {
        Section(footer: footer) {
            HealthTopRow(type: .weight, model: model)
            valueRow
            healthKitErrorCell
        }
    }
    
    var body_ : some View {
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
            unit: $settingsStore.bodyMassUnit,
            quantityInKg: $model.health.weightQuantity,
            source: model.weightSource
        )
    }
     
    var manualValue: some View {
        BodyMassField(
            unit: $settingsStore.bodyMassUnit,
            valueInKg: $model.weightValue,
            focusedType: focusedType,
            healthType: .weight
        )
    }
}

#Preview {
    @FocusState var focusedType: HealthType?
    return NavigationStack {
        Form {
            HealthWeightSections(MockHealthModel, SettingsStore.shared, $focusedType)
        }
    }
}
