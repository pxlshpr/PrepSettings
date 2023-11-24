import SwiftUI
import PrepShared

struct HealthLeanBodyMassSection: View {
    
    @Bindable var model: HealthModel
    
    init(_ model: HealthModel) {
        self.model = model
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
        ManualBodyMassField(
            unit: $model.health.bodyMassUnit,
            valueInKg: $model.leanBodyMassValue
        )
    }
    
    var calculatedValue: some View {
        CalculatedBodyMassView(
            unit: $model.health.bodyMassUnit,
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
                NumberTextField(
                    placeholder: "Required",
                    roundUp: true,
                    binding: $model.fatPercentageValue
                )
                Text("%")
                    .foregroundStyle(Color(.tertiaryLabel))
            }
        }
    }
    
    @ViewBuilder
    var healthLink: some View {
        if let leanBodyMass, leanBodyMass.source.isCalculated {
            NavigationLink {
                HealthForm(model, leanBodyMass.source.params)
            } label: {
                HStack(alignment: .firstTextBaseline) {
                    Text(model.leanBodyMassHealthLinkTitle)
                    Spacer()
                    model.health.leanBodyMassHealthLinkText
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
