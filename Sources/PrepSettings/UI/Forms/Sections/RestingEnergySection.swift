import SwiftUI
import PrepShared

struct RestingEnergySection: View {
    
    @Bindable var model: HealthModel
    @Bindable var settingsStore: SettingsStore

    var focusedType: FocusState<HealthType?>.Binding

    var body: some View {
        sourceSection
        equationSection
        equationParamsSection
        valueSection
    }
    
    var sourceSection: some View {
        Section {
            ForEach(RestingEnergySource.allCases, id: \.self) { source in
                Button {
                    model.restingEnergySource = source
                } label: {
                    HStack {
                        Text(source.menuTitle)
                            .foregroundStyle(Color(.label))
                        Spacer()
                        Image(systemName: "checkmark")
                            .opacity(model.restingEnergySource == source ? 1 : 0)
                    }
                }
            }
        }
    }
    
    var valueSection: some View {
        Section {
            valueRow
        }
    }
    
    var equationSection: some View {
        
        var section: some View {
            Section("Equation") {
                ForEach(RestingEnergyEquation.inOrderOfYear, id: \.self) { equation in
                    Button {
                        model.restingEnergyEquation = equation
                    } label: {
                        HStack {
                            Text(equation.name)
                                .foregroundStyle(Color(.label))
                            Spacer()
                            Text(equation.year)
                                .foregroundStyle(Color(.secondaryLabel))
                            Image(systemName: "checkmark")
                                .opacity(model.restingEnergyEquation == equation ? 1 : 0)
                        }
                    }
                }
            }
        }
        
        return Group {
            if model.restingEnergySource == .equation {
                section
            }
        }
    }
    
    var equationParamsSection: some View {
        var section: some View {
            Section("Health Details") {
                ForEach(model.restingEnergyEquation.params, id: \.self) { type in
                    HealthLink(type: type)
                        .environment(settingsStore)
                        .environment(model)
                }
            }
        }
        return Group {
            if model.restingEnergySource == .equation, !model.restingEnergyEquation.params.isEmpty {
                section
            }
        }
    }
    
    var body_: some View {
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
        case .healthKit:    healthContent
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
            HStack(spacing: UnitSpacing) {
                Spacer()
                NumberField(
                    placeholder: "Required",
                    roundUp: true,
                    binding: $model.health.restingEnergyValue
                )
                .focused(focusedType, equals: HealthType.restingEnergy)
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

#Preview {
    @FocusState var focusedType: HealthType?
    return NavigationStack {
        Form {
            RestingEnergySection(
                model: MockHealthModel,
                settingsStore: SettingsStore.shared,
                focusedType: $focusedType
            )
        }
    }
}
