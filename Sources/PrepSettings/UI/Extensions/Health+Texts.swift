import SwiftUI
import PrepShared

struct HealthTexts {
    
    let health: Health
    let energyUnit: EnergyUnit
    let heightUnit: HeightUnit
    let bodyMassUnit: BodyMassUnit
    
    init(_ health: Health, _ settingsStore: SettingsStore) {
        self.health = health
        self.energyUnit = settingsStore.energyUnit
        self.heightUnit = settingsStore.heightUnit
        self.bodyMassUnit = settingsStore.bodyMassUnit
    }
    
    var maintenanceEnergy: Health.MaintenanceEnergy? { health.maintenanceEnergy }
    var restingEnergy: Health.RestingEnergy? { health.restingEnergy }
    var activeEnergy: Health.ActiveEnergy? { health.activeEnergy }
    var weight: HealthQuantity? { health.weight }
    var leanBodyMass: Health.LeanBodyMass? { health.leanBodyMass }
    var height: HealthQuantity? { health.height }
    var age: Health.Age? { health.age }
    var sex: Health.BiologicalSex? { health.sex }
    var fatPercentage: Double? { health.fatPercentage }
    var pregnancyStatus: PregnancyStatus? { health.pregnancyStatus }
    var isSmoker: Bool? { health.isSmoker }
    var updatedAt: Date { health.updatedAt }
    
    var restingEnergyHealthLinkText: some View {
        healthLinkText(for: health.restingEnergyEquation.params)
    }

    var leanBodyMassHealthLinkText: some View {
        healthLinkText(for: health.leanBodyMassSource.params)
    }

    func healthLinkText(for types: [HealthType]) -> some View {
        @ViewBuilder
        func view(for type: HealthType) -> some View {
            if health.haveValue(for: type) {
                textView(for: type)
                    .foregroundStyle(.secondary)
            } else if types.count == 1 {
                Text("Required")
                    .foregroundStyle(.tertiary)
            } else {
                Text("\(type.name.lowercased().capitalizingFirstLetter()) required")
                    .foregroundStyle(.tertiary)
            }
        }

        return VStack(alignment: .trailing) {
            ForEach(types, id: \.self) { type in
                view(for: type)
            }
        }
    }
    
    @ViewBuilder
    func textView(for type: HealthType) -> some View {
        switch type {
        case .sex:                  sexText
        case .age:                  ageText
        case .weight:               weightText
        case .leanBodyMass:         leanBodyMassText
        case .height:               heightText
        case .fatPercentage:        fatPercentageText
        case .restingEnergy:        restingEnergyText
        case .activeEnergy:         activeEnergyText
        case .maintenanceEnergy:    maintenanceText
        case .pregnancyStatus:      pregnancyStatusText
        case .isSmoker:             isSmokerText
        }
    }
    
    @ViewBuilder
    var sexText: some View {
        if let sexValue = health.sexValue, sexValue != .other {
            Text(sexValue.name)
        }
    }

    @ViewBuilder
    var pregnancyStatusText: some View {
        if let pregnancyStatus {
            Text(pregnancyStatus.name)
        }
    }
    
    @ViewBuilder
    var isSmokerText: some View {
        if let isSmoker {
            Text(isSmoker ? "Yes" : "No")
        }
    }

    @ViewBuilder
    var ageText: some View {
        if let age = age?.value {
            HStack(spacing: 3) {
                Text("\(age)")
                    .font(HealthFont)
                    .contentTransition(.numericText(value: Double(age)))
                Text("years")
            }
        }
    }
    
    @ViewBuilder
    var fatPercentageText: some View {
        if let fatPercentage {
            HStack(spacing: 3) {
                Text(fatPercentage.healthString)
                    .font(HealthFont)
                    .contentTransition(.numericText(value: fatPercentage))
                Text("%")
            }
        }
    }
    
    func energyText(_ value: Double) -> some View {
        HStack(spacing: 3) {
            Text("\(value.formattedEnergy)")
                .font(HealthFont)
                .contentTransition(.numericText(value: value))
            Text("\(energyUnit.abbreviation)")
        }
    }
    
    @ViewBuilder
    var restingEnergyText: some View {
        if let value = restingEnergy?.value {
            energyText(value)
        }
    }

    @ViewBuilder
    var activeEnergyText: some View {
        if let value = activeEnergy?.value {
            energyText(value)
        }
    }
    
    @ViewBuilder
    var maintenanceText: some View {
        if let value = health.estimatedMaintenance(in: energyUnit) {
            HStack(spacing: 3) {
                Text(value.formattedEnergy)
                    .font(HealthFont)
                Text(energyUnit.abbreviation)
            }
            .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    var weightText: some View {
        if let value = health.weightQuantity?.value {
            HealthTextView(
                unit: bodyMassUnit,
                value: value,
                secondComponent: value.fraction * PoundsPerStone
            )
        }
    }
    
    @ViewBuilder
    var leanBodyMassText: some View {
        if let value = health.leanBodyMassQuantity?.value {
            HealthTextView(
                unit: bodyMassUnit,
                value: value,
                secondComponent: value.fraction * PoundsPerStone
            )
        }
    }
    
    @ViewBuilder
    var heightText: some View {
        if let value = health.heightQuantity?.value {
            HealthTextView(
                unit: heightUnit,
                value: value,
                secondComponent: value.fraction * InchesPerFoot
            )
        }
    }
}

