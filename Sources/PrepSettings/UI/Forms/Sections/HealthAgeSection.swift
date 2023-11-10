import SwiftUI
import PrepShared

extension HealthType {
    var canBeRemoved: Bool {
        switch self {
        case .restingEnergy, .activeEnergy, .fatPercentage:
            false
        default:
            true
        }
    }
}
struct HealthTopRow: View {
    
    let type: HealthType
    @Bindable var model: HealthModel
    
    var body: some View {
        HStack(alignment: verticalAlignment) {
            removeButton
            Text(type.name)
                .fontWeight(.semibold)
            Spacer()
            content
                .multilineTextAlignment(.trailing)
        }
    }
    
    var verticalAlignment: VerticalAlignment {
        switch type {
        case .maintenanceEnergy:
            model.isSettingMaintenanceFromHealthKit ? .center : .firstTextBaseline
        default:
            .firstTextBaseline
        }
    }
    
    @ViewBuilder
    var removeButton: some View {
        if type.canBeRemoved {
            Button {
                withAnimation {
                    model.remove(type)
                }
            } label: {
                Image(systemName: "minus.circle.fill")
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
        }
    }
    
    @ViewBuilder
    var content: some View {
        switch type {
        case .maintenanceEnergy:
            maintenanceContent
        case .restingEnergy:
            MenuPicker($model.restingEnergySource)
        case .activeEnergy:
            MenuPicker($model.activeEnergySource)
        case .sex:
            MenuPicker($model.sexSource)
        case .age:
            MenuPicker($model.ageSource)
        case .weight:
            MenuPicker($model.weightSource)
        case .leanBodyMass:
            MenuPicker($model.leanBodyMassSource)
        case .height:
            MenuPicker($model.heightSource)
        case .pregnancyStatus:
            MenuPicker([.pregnant, .lactating], $model.pregnancyStatus)
        case .isSmoker:
            Toggle("", isOn: $model.isSmoker)
        case .fatPercentage:
            EmptyView()
        }
    }
    
    var maintenanceContent: some View {
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
                Text(model.health.energyUnit.abbreviation)
                    .foregroundStyle(.secondary)
                    .font(.system(.body, design: .default, weight: .semibold))
            }
        }
        
        var loadingContent: some View {
            ProgressView()
                .fixedSize(horizontal: true, vertical: false)
        }
        
        return Group {
            if model.isSettingMaintenanceFromHealthKit {
                loadingContent
            } else if let message = model.health.tdeeRequiredString {
                emptyContent(message)
            } else if let value = model.health.maintenanceEnergy {
                valueContent(value)
            } else {
                EmptyView()
            }
        }
    }
}

struct HealthAgeSection: View {
    
    @Bindable var model: HealthModel

    init(_ model: HealthModel) {
        self.model = model
    }
    
    var body: some View {
        Section(header: header, footer: footer) {
            HealthTopRow(type: .age, model: model)
            dateOfBirthPickerField
            valueRow
            healthKitErrorCell
        }
    }
    
    var header: some View {
        EmptyView()
//        HealthHeader(type: .age)
//            .environment(model)
    }
    
    var footer: some View {
        HealthFooter(
            source: model.ageSource,
            type: .age,
            hasQuantity: model.health.age?.value != nil
        )
    }
    
    @ViewBuilder
    var healthKitErrorCell: some View {
        if model.health.ageSource == .healthKit, model.health.age?.value == nil {
            HealthKitErrorCell(type: .age)
        }
    }
    
    var valueRow: some View {
        HStack {
            Spacer()
            switch model.ageSource {
            case .healthKit, .userEnteredDateOfBirth:
                computedContent
            case .userEnteredAge:
                NumberTextField(placeholder: "Required", binding: $model.ageValue)
            }
            if model.health.age?.value != nil {
                Text("years")
                    .foregroundStyle(Color(.tertiaryLabel))
            }
        }
    }
    
    var computedContent: some View {
        
        var placeholder: String {
            switch model.ageSource {
            case .healthKit:
                "Unavailable"
            case .userEnteredDateOfBirth:
                "Choose your date of birth"
            case .userEnteredAge:
                "Not set"
            }
        }
        
        return Group {
            if let age = model.health.age?.value {
                Text("\(age)")
                    .font(HealthFont)
                    .foregroundStyle(.secondary)
            } else {
                Text(placeholder)
                    .foregroundStyle(.tertiary)
            }
        }
    }
    
    var dateOfBirthBinding: Binding<Date> {
        Binding<Date>(
            get: { model.health.ageDateOfBirth ?? DefaultDateOfBirth },
            set: { model.health.ageDateOfBirth = $0 }
        )
    }
    
    @ViewBuilder
    var dateOfBirthPickerField: some View {
        if model.ageSource == .userEnteredDateOfBirth {
            HStack {
                Text("Date of birth")
                Spacer()
                DatePicker(
                    "",
                    selection: dateOfBirthBinding,
                    displayedComponents: [.date]
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        Form {
            HealthAgeSection(MockHealthModel)
        }
    }
}
