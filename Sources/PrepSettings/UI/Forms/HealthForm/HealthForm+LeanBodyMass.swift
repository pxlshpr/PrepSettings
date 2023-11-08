import SwiftUI
import PrepShared

extension HealthForm {
    
    var leanBodyMass: Health.LeanBodyMass {
        model.health.leanBodyMass ?? .init(source: .default)
    }

    var leanBodyMassSection: some View {
        
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
        
        @ViewBuilder
        var equationPicker: some View {
            if leanBodyMass.source == .equation {
                PickerField("Equation", $model.leanBodyMassEquation)
            }
        }
        
        @ViewBuilder
        var fatPercentageField: some View {
            if leanBodyMass.source == .fatPercentage {
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
            if leanBodyMass.source.isCalculated {
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

        var valueField: some View {
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
        
        return Section(
            header: Text("Lean Body Mass"),
            footer: HealthFooter(
                source: model.leanBodyMassSource,
                type: .leanBodyMass,
                hasQuantity: model.health.leanBodyMassQuantity != nil
            )
        ) {
            HealthSourcePicker(sourceBinding: $model.leanBodyMassSource)
            equationPicker
            healthLink
            fatPercentageField
            valueField
        }
    }
}
