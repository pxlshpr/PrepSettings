import SwiftUI
import PrepShared
import PrepSettings

public extension Biometrics {

    var restingEnergyBiometricsLinkText: some View {
        biometricsLinkText(for: restingEnergyEquation.params)
    }

    var leanBodyMassBiometricsLinkText: some View {
        biometricsLinkText(for: leanBodyMassSource.params)
    }

    func biometricsLinkText(for types: [BiometricType]) -> some View {
        @ViewBuilder
        func view(for type: BiometricType) -> some View {
            if haveValue(for: type) {
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
    func textView(for type: BiometricType) -> some View {
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
        }
    }
    
    @ViewBuilder
    var sexText: some View {
        if let sexValue, sexValue != .notSpecified {
            Text(sexValue.name)
        }
    }
    
    @ViewBuilder
    var ageText: some View {
        if let age = age?.value {
            HStack(spacing: 3) {
                Text("\(age)")
                    .font(BiometricFont)
                    .contentTransition(.numericText(value: Double(age)))
                Text("years")
            }
        }
    }
    
    @ViewBuilder
    var fatPercentageText: some View {
        if let fatPercentage {
            HStack(spacing: 3) {
                Text(fatPercentage.biometricString)
                    .font(BiometricFont)
                    .contentTransition(.numericText(value: fatPercentage))
                Text("%")
            }
        }
    }
    
    func energyText(_ value: Double) -> some View {
        HStack(spacing: 3) {
            Text("\(value.formattedEnergy)")
                .font(BiometricFont)
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
        if let maintenanceEnergy {
            HStack(spacing: 3) {
                Text(maintenanceEnergy.formattedEnergy)
                    .font(BiometricFont)
                Text(energyUnit.abbreviation)
            }
            .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    var weightText: some View {
        if let value = weightQuantity?.value {
            BiometricTextView(
                unit: bodyMassUnit,
                value: value,
                secondComponent: value.fraction * PoundsPerStone
            )
        }
    }
    
    @ViewBuilder
    var leanBodyMassText: some View {
        if let value = leanBodyMassQuantity?.value {
            BiometricTextView(
                unit: bodyMassUnit,
                value: value,
                secondComponent: value.fraction * PoundsPerStone
            )
        }
    }
    
    @ViewBuilder
    var heightText: some View {
        if let value = heightQuantity?.value {
            BiometricTextView(
                unit: heightUnit,
                value: value,
                secondComponent: value.fraction * InchesPerFoot
            )
        }
    }
}

