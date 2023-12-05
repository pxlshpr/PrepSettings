import SwiftUI
import PrepShared

/// [x] Animation from progress view to setting an adaptive value is missing
/// [x] Consider always having text placed and simply use opacity to hide it when showing the progresss view, error view, etc (we already have a copy of it so use that perhaps)
/// [ ] Fix up the value row while testing having estimate's components missing (resting or active), because their texts might need alignment
struct MaintenanceValueSection: View {

    @Environment(SettingsStore.self) var settingsStore: SettingsStore

    @Environment(\.colorScheme) var colorScheme

    let type = HealthType.maintenanceEnergy
    @Bindable var model: HealthModel

    init(_ model: HealthModel) {
        self.model = model
    }

    var body: some View {
        Section(footer: footer) {
            VStack {
                topRow
                /// Conditionally show the bottom row, only if we have the value, so that we don't get shown the default source values for a split second during the removal animations.
                if model.health.hasType(type) {
                    bottomRow
                } else {
                    EmptyView()
                }
            }
        }
    }
    
    var footer: some View {
        Text(HealthType.maintenanceEnergy.reason!)
    }

    @ViewBuilder
    var topRow: some View {
        if model.hasAdaptiveMaintenanceEnergyValue {
            Picker("", selection: $model.maintenanceEnergyIsAdaptive) {
                Text("Adaptive").tag(true)
                Text("Estimated").tag(false)
            }
            .pickerStyle(.segmented)
        }
    }
    
    var topRow_: some View {
        HStack(alignment: verticalAlignment) {
            Spacer()
            calculatedTag
        }
    }
    
    var bottomRow: some View {
        HStack {
            Spacer()
            detail
                .multilineTextAlignment(.trailing)
        }
    }
    
    var showAdaptive: Bool {
        model.hasAdaptiveMaintenanceEnergyValue
    }
    
    var calculatedTag: some View {
        
        var string: String {
//            showAdaptive ? "Adaptive" : "Estimated"
//            showAdaptive ? "Calculated" : "Estimated"
            showAdaptive ? "Adaptive" : "Estimate"
        }
        
        var foregroundColor: Color {
            Color(showAdaptive ? .white : .secondaryLabel)
        }
        
        var backgroundColor: Color {
            showAdaptive ? Color.accentColor : Color(colorScheme == .dark ? .systemGray4 : .systemGray5)
        }
        
        var fontWeight: Font.Weight {
            showAdaptive ? .semibold : .regular
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
    
    var detail: some View {
        func emptyContent(_ message: String) -> some View {
            Text(message)
                .foregroundStyle(.tertiary)
        }
        
        var foregroundColor: Color {
            .primary
        }
        
        func valueContent(_ value: Double) -> some View {
            LargeHealthValue(
                value: value,
                unitString: settingsStore.energyUnit.abbreviation
            )
        }
        
        var loadingContent: some View {
            ProgressView()
                .fixedSize(horizontal: true, vertical: false)
        }
        
        var value: Double {
            if model.maintenanceEnergyIsAdaptive,
               let value = model.health.maintenanceEnergy?.adaptiveValue,
                model.health.maintenanceEnergy?.error == nil
            {
                value
            } else if let value = model.health.estimatedMaintenance(in: settingsStore.energyUnit) {
                value
            } else {
                0
            }
        }
        
        @ViewBuilder
        var content: some View {
            if !model.hasAdaptiveMaintenanceEnergyValue {
                if model.isSettingMaintenanceFromHealthKit {
                    loadingContent
                } else if let message = model.health.tdeeRequiredString {
                    emptyContent(message)
                }
            }
        }
        
        var showValue: Bool {
            model.hasMaintenanceValue
        }
        
        return ZStack(alignment: .trailing) {
            content
            valueContent(value)
                .opacity(showValue ? 1 : 0)
        }
    }
}

#Preview {
    NavigationStack {
        HealthSummary(model: MockHealthModel)
            .environment(SettingsStore.shared)
    }
}

