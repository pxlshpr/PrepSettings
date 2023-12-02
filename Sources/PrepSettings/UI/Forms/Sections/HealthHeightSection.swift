import SwiftUI
import PrepShared

struct HealthHeightSection: View {
    
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
            unit: $settingsStore.heightUnit,
            quantityInCm: $model.health.heightQuantity,
            source: model.heightSource
        )
    }

    var manualValue: some View {
        HeightField(
            unit: $settingsStore.heightUnit,
            valueInCm: $model.heightValue,
            focusedType: focusedType
        )
    }
}
