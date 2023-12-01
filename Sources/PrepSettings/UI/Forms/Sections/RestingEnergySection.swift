import SwiftUI
import PrepShared

struct RestingEnergySection: View {
    
    @Bindable var model: HealthModel
    @Bindable var settingsStore: SettingsStore

    var body: some View {
        Section(footer: footer) {
            HealthTopRow(type: .restingEnergy, model: model)
            content
        }
    }
    
    var footer: some View {
        Text(HealthType.restingEnergy.reason!)
    }

    @ViewBuilder
    var content: some View {
        switch model.restingEnergySource {
        case .healthKit:      healthContent
        case .equation:     equationContent
        case .userEntered:  valueRow
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
            valueRow
        }
    }

    enum Route {
        case params
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
            
            return NavigationLink(value: Route.params) {
                HStack(alignment: .firstTextBaseline) {
                    Text(title)
                    Spacer()
                    HealthTexts(model.health, settingsStore).restingEnergyHealthLinkText
                }
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .params:
                    HealthForm(model)
                        .environment(settingsStore)
                }
            }
        }
        
        return Group {
            PickerField("Equation", $model.restingEnergyEquation)
            healthLink
            valueRow
            healthKitErrorCell
        }
    }
    
    @ViewBuilder
    var healthKitErrorCell: some View {
        if model.shouldShowHealthKitError(for: .restingEnergy) {
            HealthKitErrorCell(type: .restingEnergy)
        }
    }

    var valueRow: some View {
        var calculatedValue: some View {
            CalculatedEnergyView(
                valueBinding: $model.health.restingEnergyValue,
//                unitBinding: $model.health.energyUnit,
                unitBinding: $settingsStore.energyUnit,
                intervalBinding: $model.restingEnergyInterval,
                date: model.health.date,
                source: model.restingEnergySource
            )
        }
        
        var manualValue: some View {
            let binding = Binding<Double>(
                get: { model.health.restingEnergyValue ?? 0 },
                set: { model.health.restingEnergyValue = $0 }
            )

            return HStack(spacing: UnitSpacing) {
                Spacer()
                NumberTextField(placeholder: "Required", roundUp: true, binding: binding)
                /// Previously used a picker, but we've since removed it in favour of having unit changes in one place
//                MenuPicker<EnergyUnit>($settingsStore.energyUnit)
                Text(settingsStore.energyUnit.abbreviation)
                    .foregroundStyle(.secondary)
            }
        }
        
        return HStack {
            Spacer()
            if model.isSettingTypeFromHealthKit(.restingEnergy) {
                ProgressView()
            } else {
                switch model.restingEnergySource.isManual {
                case true:
                    manualValue
                case false:
                    calculatedValue
                }
            }
        }        
    }
}

