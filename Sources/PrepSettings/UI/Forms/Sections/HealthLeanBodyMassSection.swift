import SwiftUI
import PrepShared

struct HealthLeanBodyMassSection: View {
    
    @Bindable var model: HealthModel
    
    init(_ model: HealthModel) {
        self.model = model
    }
    
    var body: some View {
        Section(footer: footer) {
//            HealthSourcePicker(sourceBinding: $model.leanBodyMassSource)
            HealthTopRow(type: .leanBodyMass, model: model)
            equationPicker
            healthLink
            fatPercentageField
            valueRow
        }
    }
    
    var header: some View {
        HealthHeader(type: .leanBodyMass)
            .environment(model)
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
        if model.health.leanBodyMassSource == .healthKit, model.health.leanBodyMass?.quantity == nil {
            HealthKitErrorCell(type: .leanBodyMass)
        }
    }
    
    var manualValue: some View {
        ManualHealthField(
            unitBinding: $model.healthLeanBodyMassUnit,
            valueBinding: $model.leanBodyMassValue,
            firstComponentBinding: $model.leanBodyMassStonesComponent,
            secondComponentBinding: $model.leanBodyMassPoundsComponent
        )
    }

    var calculatedValue: some View {
        CalculatedHealthView(
            quantityBinding: $model.health.leanBodyMassQuantity,
            secondComponent: model.leanBodyMassPoundsComponent,
            unitBinding: $model.healthLeanBodyMassUnit,
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
