import SwiftUI
import PrepShared

/// [ ] Add footer for when HealthKit values aren't available

public struct TDEEForm: View {
    @Bindable var model: HealthModel

    public init(_ model: HealthModel) {
        self.model = model
    }

    public var body: some View {
        Form {
            TDEEFormSections(model)
        }
        .navigationTitle("Maintenance Energy")
        .scrollDismissesKeyboard(.interactively)
    }
}

public struct TDEEFormSections: View {
    
    @Bindable var model: HealthModel
    
    public init(_ model: HealthModel) {
        self.model = model
    }
    
    public var body: some View {
        Group {
            maintenanceSection
                .listSectionSpacing(0)
            symbol("=")
                .listSectionSpacing(0)
            RestingSection(model: model)
                .listSectionSpacing(0)
            symbol("+")
                .listSectionSpacing(0)
            ActiveSection(model: model)
                .listSectionSpacing(0)
        }
    }
    
    var health: Health {
        model.health
    }
    
    func symbol(_ string: String) -> some View {
        Text(string)
            .frame(maxWidth: .infinity, alignment: .center)
            .font(.system(.title, design: .rounded, weight: .semibold))
            .foregroundColor(.secondary)
            .listRowBackground(EmptyView())
    }

    var maintenanceSection: some View {
        func emptyContent(_ message: String) -> some View {
            Text(message)
                .foregroundStyle(.tertiary)
        }
        
        func valueContent(_ value: Double) -> some View {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value.formattedEnergy)
                    .animation(.default, value: value)
                    .contentTransition(.numericText(value: value))
                    .font(.system(.body, design: .monospaced, weight: .bold))
                    .foregroundStyle(.secondary)
                Text(health.energyUnit.abbreviation)
                    .foregroundStyle(.secondary)
                    .font(.system(.body, design: .default, weight: .semibold))
            }
//            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        
        return Section {
            HealthTopRow(type: .maintenanceEnergy, model: model)
//            HStack {
//                Text("Maintenance Energy")
//                Spacer()
//                if let message = health.tdeeRequiredString {
//                    emptyContent(message)
//                } else if let value = health.maintenanceEnergy {
//                    valueContent(value)
//                } else {
//                    EmptyView()
//                }
//            }
        }
    }
    var maintenanceSection_: some View {
        var header: some View {
            HStack(alignment: .lastTextBaseline) {
                HealthHeaderText("Maintenance Energy", isLarge: true)
                Spacer()
                Button("Remove") {
                    withAnimation {
                        model.remove(.maintenanceEnergy)
                    }
                }
                .textCase(.none)
            }
        }
        
        var footer: some View {
            Text(HealthType.maintenanceEnergy.reason!)
        }
        
        return Section(header: header) {
            if let requiredString = health.tdeeRequiredString {
                Text(requiredString)
                    .foregroundStyle(Color(.tertiaryLabel))
            } else {
                if let maintenanceEnergy = health.maintenanceEnergy {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(maintenanceEnergy.formattedEnergy)
                            .animation(.default, value: maintenanceEnergy)
                            .contentTransition(.numericText(value: maintenanceEnergy))
                            .font(.system(.largeTitle, design: .monospaced, weight: .bold))
                            .foregroundStyle(.secondary)
                        Text(health.energyUnit.abbreviation)
                            .foregroundStyle(Color(.tertiaryLabel))
                            .font(.system(.body, design: .rounded, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
    }
}

extension TDEEFormSections {
    
    struct ActiveSection: View {
        @Bindable var model: HealthModel
    }
}

extension TDEEFormSections.ActiveSection {
    
    var body: some View {
        Section(footer: footer) {
            HealthTopRow(type: .activeEnergy, model: model)
            content
        }
    }
    
    var footer: some View {
        Text(HealthType.maintenanceEnergy.reason!)
    }
    
    @ViewBuilder
    var content: some View {
        switch model.activeEnergySource {
        case .healthKit:           healthContent
        case .activityLevel:    activityContent
        case .userEntered:      valueRow
        }
    }
    
    var healthContent: some View {
        
        @ViewBuilder
        var intervalField: some View {
            HealthEnergyIntervalField(
                type: model.activeEnergyIntervalType,
                value: $model.activeEnergyIntervalValue,
                period: $model.activeEnergyIntervalPeriod
            )
        }
        
        return Group {
            PickerField("Use", $model.activeEnergyIntervalType)
            intervalField
            valueRow
            healthKitErrorCell
        }
    }
    
    @ViewBuilder
    var healthKitErrorCell: some View {
        if model.shouldShowHealthKitError(for: .activeEnergy) {
            HealthKitErrorCell(type: .activeEnergy)
        }
    }
    
    var activityContent: some View {
        Group {
            PickerField("Activity level", $model.activeEnergyActivityLevel)
            valueRow
        }
    }

    var valueRow: some View {
        var calculatedValue: some View {
            CalculatedEnergyView(
                valueBinding: $model.health.activeEnergyValue,
                unitBinding: $model.activeEnergyUnit,
                intervalBinding: $model.activeEnergyInterval,
                date: model.health.date,
                source: model.activeEnergySource
            )
        }
        
        var manualValue: some View {
            let binding = Binding<Double>(
                get: { model.health.activeEnergyValue ?? 0 },
                set: { model.health.activeEnergyValue = $0 }
            )

            return HStack {
                Spacer()
                NumberTextField(placeholder: "Required", roundUp: true, binding: binding)
                MenuPicker<EnergyUnit>($model.activeEnergyUnit)
            }
        }
        
        return HStack {
            Spacer()
            if model.isSettingTypeFromHealthKit(.activeEnergy) {
                ProgressView()
            } else {
                switch model.activeEnergySource.isManual {
                case true:
                    manualValue
                case false:
                    calculatedValue
                }
            }
        }
        
        //TODO: Remove this
//        HealthEnergyValueField(
//            value: $model.health.activeEnergyValue,
//            energyUnit: $model.activeEnergyUnit,
//            interval: $model.activeEnergyInterval,
//            date: model.health.date,
//            source: model.activeEnergySource
//        )
    }
}

extension TDEEFormSections {
    
    struct RestingSection: View {
        @Bindable var model: HealthModel
    }
}

extension TDEEFormSections.RestingSection {
    
    var body: some View {
        Section {
            HealthTopRow(type: .restingEnergy, model: model)
            content
        }
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
                unitBinding: $model.restingEnergyUnit,
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

            return HStack {
                Spacer()
                NumberTextField(placeholder: "Required", roundUp: true, binding: binding)
                MenuPicker<EnergyUnit>($model.restingEnergyUnit)
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
        
        //TODO: Remove this
//        HealthEnergyValueField(
//            value: $model.health.restingEnergyValue,
//            energyUnit: $model.restingEnergyUnit,
//            interval: $model.restingEnergyInterval,
//            date: model.health.date,
//            source: model.restingEnergySource
//        )
    }
}


#Preview {
    NavigationView {
        TDEEForm(MockHealthModel)
    }
}

struct HealthHeaderText: View {
    let string: String
    let isLarge: Bool
    init(_ string: String, isLarge: Bool = false) {
        self.string = string
        self.isLarge = isLarge
    }
    
    var body: some View {
        Text(string)
            .font(.system(isLarge ? .title2 : .title3, design: .rounded, weight: .bold))
            .textCase(.none)
            .foregroundStyle(Color(.label))
    }
}
