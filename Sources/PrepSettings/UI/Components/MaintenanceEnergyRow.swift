import SwiftUI
import PrepShared

/// [x] Animation from progress view to setting an adaptive value is missing
/// [x] Consider always having text placed and simply use opacity to hide it when showing the progresss view, error view, etc (we already have a copy of it so use that perhaps)
/// [ ] Fix up the value row while testing having estimate's components missing (resting or active), because their texts might need alignment
struct MaintenanceEnergyRow: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let type = HealthType.maintenanceEnergy
    @Bindable var model: HealthModel
    
//    @State var showingAdaptiveDetails: Bool = false

    init(_ model: HealthModel) {
        self.model = model
    }
    
    var body: some View {
        Group {
            VStack {
                topRow
                /// Conditionally show the bottom row, only if we have the value, so that we don't get shown the default source values for a split second during the removal animations.
                if model.health.hasType(type) {
                    bottomRow
                } else {
                    EmptyView()
                }
            }
            viewDataRow
            errorRow
//            viewDataButton
        }
//        .sheet(isPresented: $showingAdaptiveDetails) { adaptiveDetails }
    }
    
    @ViewBuilder
    var errorRow: some View {
        if let error = model.health.maintenanceEnergy?.error {
            AdaptiveCalculationErrorCell(error)
        }
    }
    
    var topRow: some View {
        HStack(alignment: verticalAlignment) {
            removeButton
            Text(type.name)
//            Text(type.name + " Energy")
                .fontWeight(.semibold)
            Spacer()
            calculatedTag
        }
    }
    
    var bottomRow: some View {
        HStack {
//            calculatedTag
//            viewDataButton
            Spacer()
            detail
                .multilineTextAlignment(.trailing)
        }
    }
    
    var viewDataRow: some View {
        NavigationLink {
            AdaptiveDataList()
        } label: {
            Text("Show Data")
        }
    }


    var showingAdaptive: Bool {
        model.maintenanceEnergyIsCalculated
        && model.maintenanceEnergyCalculatedValue != nil
        && model.maintenanceEnergyCalculationError == nil
    }
    
    var calculatedTag: some View {
        
        var string: String {
            showingAdaptive ? "Adaptive" : "Estimated"
        }
        
        var foregroundColor: Color {
            Color(showingAdaptive ? .white : .secondaryLabel)
        }
        
        var backgroundColor: Color {
            showingAdaptive ? Color.accentColor : Color(colorScheme == .dark ? .systemGray4 : .systemGray5)
        }
        
        var fontWeight: Font.Weight {
            showingAdaptive ? .semibold : .regular
        }
        
        return TagView(
            string: string,
            foregroundColor: foregroundColor,
            backgroundColor: backgroundColor,
            fontWeight: fontWeight
        )
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
    
    var detail: some View {
        func emptyContent(_ message: String) -> some View {
            Text(message)
                .foregroundStyle(.tertiary)
        }
        
        var foregroundColor: Color {
            .primary
        }
        
        func valueContent(_ value: Double) -> some View {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value.formattedEnergy)
                    .animation(.default, value: value)
                    .contentTransition(.numericText(value: value))
//                    .font(.system(.body, design: .monospaced, weight: .bold))
                    .font(.system(.largeTitle, design: .monospaced, weight: .bold))
                    .foregroundStyle(foregroundColor)
                Text(model.health.energyUnit.abbreviation)
                    .foregroundStyle(foregroundColor)
                    .font(.system(.body, design: .default, weight: .semibold))
            }
        }
        
        var loadingContent: some View {
            ProgressView()
                .fixedSize(horizontal: true, vertical: false)
        }
        
        var value: Double {
            if model.maintenanceEnergyIsCalculated,
                let value = model.maintenanceEnergyCalculatedValue,
                model.health.maintenanceEnergy?.error == nil
            {
                value
            } else if let value = model.health.estimatedEnergyBurn {
                value
            } else {
                0
            }
        }
        
        @ViewBuilder
        var content: some View {
            if model.isSettingMaintenanceFromHealthKit {
                loadingContent
            } else if let message = model.health.tdeeRequiredString {
                emptyContent(message)
            }
//            } else if let value {
//                valueContent(value)
//            } else {
//                EmptyView()
//            }
        }
        
        var valueOpacity: CGFloat {
            model.isSettingMaintenanceFromHealthKit ? 0 : 1
        }
        
        return ZStack(alignment: .trailing) {
            content
            valueContent(value)
                .opacity(valueOpacity)
//                .opacity(0)
        }
    }
}

public enum MaintenanceCalculationError: Int, Codable {
    case noWeightData = 1
    case noNutritionData
    case noWeightOrNutritionData
    
    var message: String {
        switch self {
        case .noWeightData:
//            "You do not have enough weight data over the prior week to make a calculation."
            "You do not have enough weight data to make a calculation."
        case .noNutritionData:
            "You do not have any nutrition data to make a calculation."
        case .noWeightOrNutritionData:
            "You do not have enough weight and nutrition data to make an adaptive calculation."
        }
    }
    
    var title: String {
        switch self {
        case .noWeightData:
            "Insufficient Weight Data"
        case .noNutritionData:
            "Insufficient Nutrition Data"
        case .noWeightOrNutritionData:
            "Insufficient Data"
        }
    }
}

/// [ ] If there is no weight data—show "
/// [ ] When this is the first time user is using this, let them
/// [ ] Always give the user
struct AdaptiveCalculationErrorCell: View {
    
    let error: MaintenanceCalculationError
    
    init(_ error: MaintenanceCalculationError) {
        self.error = error
    }
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "info.circle")
                .font(.system(size: 50))
                .foregroundStyle(Color.accentColor)
            VStack(alignment: .leading) {
                Text(error.title)
                    .fontWeight(.semibold)
                Text(error.message  + " " + secondaryMessage)
                    .font(.system(.callout))
                    .foregroundStyle(.secondary)
//                Divider()
//                Text(secondaryMessage)
//                    .font(.system(.callout))
//                    .foregroundStyle(Color(.secondaryLabel))
//                Divider()
//                setDataButton
            }
        }
    }
    
//    var setDataButton: some View {
//        Button {
//            showingAdaptiveDetails = true
//        } label: {
//            Text("Show Data")
//                .fontWeight(.semibold)
//                .foregroundStyle(Color.accentColor)
//        }
//        .buttonStyle(.plain)
//        .padding(.top, 5)
//    }
    
    var secondaryMessage: String {
        "Your estimated maintenance energy is being used instead."
    }
}

#Preview {
    NavigationStack {
        HealthSummary(model: MockHealthModel)
    }
}

