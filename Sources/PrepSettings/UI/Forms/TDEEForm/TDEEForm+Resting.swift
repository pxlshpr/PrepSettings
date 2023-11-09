import SwiftUI
import HealthKit
import PrepShared

/// [ ] Add footer for when HealthKit values aren't available

extension TDEEForm {
    
    struct RestingSection: View {
        @Bindable var model: HealthModel
    }
}

extension TDEEForm.RestingSection {
    
    var body: some View {
        Section("Resting Energy") {
            HealthSourcePicker(sourceBinding: $model.restingEnergySource)
            content
        }
    }
    
    @ViewBuilder
    var content: some View {
        switch model.restingEnergySource {
        case .healthKit:       healthContent
        case .equation:     equationContent
        case .userEntered:  bottomRow
        }
    }
    
    var healthContent: some View {
        
        @ViewBuilder
        var intervalField: some View {
            HealthEnergyIntervalField(
                type: model.restingEnergyIntervalType,
                value: $model.restingEnergyIntervalValue,
                period: $model.restingEnergyIntervalPeriod
            )
        }
        
        return Group {
            PickerField("Use", $model.restingEnergyIntervalType)
            intervalField
            bottomRow
        }
    }

    var equationContent: some View {
        var healthLink: some View {
            var params: [HealthType] {
                model.restingEnergyEquation.params
            }
            
            var title: String {
                if params.count == 1, let param = params.first {
                    param.name
                } else {
                    "Health Details"
                }
            }
            
            return NavigationLink {
                HealthForm(model)
            } label: {
                HStack(alignment: .firstTextBaseline) {
                    Text(title)
                    Spacer()
                    model.health.restingEnergyHealthLinkText
                }
            }
        }
        
        return Group {
            PickerField("Equation", $model.restingEnergyEquation)
            healthLink
            bottomRow
        }
    }
    
    var bottomRow: some View {
        HealthEnergyValueField(
            value: $model.health.restingEnergyValue,
            energyUnit: $model.restingEnergyUnit,
            interval: $model.restingEnergyInterval,
            date: model.health.date,
            source: model.restingEnergySource
        )
    }
}
