import SwiftUI
import PrepShared

struct HealthTopRow: View {
    
    let type: HealthType
    @Bindable var model: HealthModel
    
    var body: some View {
        HStack(alignment: verticalAlignment) {
            removeButton
            Text(type.name)
                .fontWeight(.semibold)
            Spacer()
            /// Conditionally show the detail content (usually the source picker), only if we have the value, so that
            /// we don't get shown the default source values for a split second during the removal animations.
            if model.health.hasType(type) {
                detailContent
                    .multilineTextAlignment(.trailing)
            } else {
                EmptyView()
            }
        }
    }
    
    var verticalAlignment: VerticalAlignment {
        switch type {
        case .maintenance:
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
    var detailContent: some View {
        switch type {
        case .restingEnergy:
            MenuPicker($model.restingEnergySource)
        case .activeEnergy:
            MenuPicker($model.activeEnergySource)
        case .sex:
            MenuPicker($model.sexSource)
        case .age:
            MenuPicker($model.ageSource)
        case .weight:
            EmptyView()
//            MenuPicker($model.weightSource)
        case .leanBodyMass:
            MenuPicker($model.leanBodyMassSource)
        case .height:
            MenuPicker($model.heightSource)
        case .pregnancyStatus:
            MenuPicker([.pregnant, .lactating], $model.pregnancyStatus)
        case .isSmoker:
            Toggle("", isOn: $model.isSmoker)
        default:
            EmptyView()
        }
    }
    
//    var maintenanceContent: some View {
//        func emptyContent(_ message: String) -> some View {
//            Text(message)
//                .foregroundStyle(.tertiary)
//        }
//        
//        func valueContent(_ value: Double) -> some View {
//            HStack(alignment: .firstTextBaseline, spacing: 4) {
//                Text(value.formattedEnergy)
//                    .animation(.default, value: value)
//                    .contentTransition(.numericText(value: value))
//                    .font(NumberFont)
//                    .foregroundStyle(.secondary)
//                Text(model.health.energyUnit.abbreviation)
//                    .foregroundStyle(.secondary)
//                    .font(.system(.body, design: .default, weight: .semibold))
//            }
//        }
//        
//        var loadingContent: some View {
//            ProgressView()
//                .fixedSize(horizontal: true, vertical: false)
//        }
//        
//        return Group {
//            if model.isSettingMaintenanceFromHealthKit {
//                loadingContent
//            } else if let message = model.health.tdeeRequiredString {
//                emptyContent(message)
//            } else if let value = model.health.estimatedMaintenance {
//                valueContent(value)
//            } else {
//                EmptyView()
//            }
//        }
//    }
}
