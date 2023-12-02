import SwiftUI
import PrepShared

struct HealthLeanBodyMassSection: View {
    
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
            HealthTopRow(type: .leanBodyMass, model: model)
            equationPicker
            healthLink
            fatPercentageField
            valueRow
        }
    }
    
    var footer: some View {
        HealthFooter(
            source: model.leanBodyMassSource,
            type: .leanBodyMass,
            hasQuantity: model.health.leanBodyMassQuantity != nil
        )
    }
    
    @ViewBuilder
    var healthKitErrorCell: some View {
        if model.shouldShowHealthKitError(for: .leanBodyMass) {
            HealthKitErrorCell(type: .leanBodyMass)
        }
    }

    var manualValue: some View {
        BodyMassField(
            unit: $settingsStore.bodyMassUnit,
            valueInKg: $model.leanBodyMassValue,
            focusedType: focusedType,
            healthType: .leanBodyMass
        )
    }
    
    var calculatedValue: some View {
        CalculatedBodyMassView(
            unit: $settingsStore.bodyMassUnit,
            quantityInKg: $model.health.leanBodyMassQuantity,
            source: model.leanBodyMassSource
        )
    }
    
    var leanBodyMass: Health.LeanBodyMass? {
        model.health.leanBodyMass
    }
    
    @ViewBuilder
    var equationPicker: some View {
        if let leanBodyMass, leanBodyMass.source == .equation {
            PickerField("Equation", $model.leanBodyMassEquation)
        }
    }
    
    @ViewBuilder
    var fatPercentageField: some View {
        if let leanBodyMass, leanBodyMass.source == .fatPercentage {
            HStack {
                Text("Fat Percentage")
                Spacer()
                NumberField(
                    placeholder: "Required",
                    roundUp: true,
                    binding: $model.fatPercentageValue
                )
                .focused(focusedType, equals: HealthType.fatPercentage)
                Text("%")
                    .foregroundStyle(Color(.tertiaryLabel))
            }
        }
    }
    
    enum Route {
        case params
    }
    
    @ViewBuilder
    var healthLink: some View {
        if let leanBodyMass, leanBodyMass.source.isCalculated {
            NavigationLink(value: Route.params) {
                HStack(alignment: .firstTextBaseline) {
                    Text(model.leanBodyMassHealthLinkTitle)
                    Spacer()
                    HealthTexts(model.health, settingsStore).leanBodyMassHealthLinkText
                }
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .params:
                    HealthForm(model, leanBodyMass.source.params)
                        .environment(settingsStore)
                }
            }
        }
    }
    
    @ViewBuilder
    var valueRow: some View {
        if let leanBodyMass {
            HStack {
                Spacer()
                if model.isSettingTypeFromHealthKit(.leanBodyMass) {
                    ProgressView()
                } else {
                    switch leanBodyMass.source {
                    case .healthKit, .equation, .fatPercentage:
                        calculatedValue
                    case .userEntered:
                        manualValue
                    }
                }
            }
        }
    }
}

#Preview {
    Text("")
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
                HealthSummary(model: MockHealthModel)
                    .environment(SettingsStore.shared)
            }
        }
}
