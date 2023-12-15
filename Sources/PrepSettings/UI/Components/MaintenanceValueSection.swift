import SwiftUI
import PrepShared

/// [x] Animation from progress view to setting an adaptive value is missing
/// [x] Consider always having text placed and simply use opacity to hide it when showing the progresss view, error view, etc (we already have a copy of it so use that perhaps)
/// [ ] Fix up the value row while testing having estimate's components missing (resting or active), because their texts might need alignment
struct MaintenanceValueSection: View {

    @Environment(SettingsStore.self) var settingsStore: SettingsStore

    @Environment(\.colorScheme) var colorScheme

    let type = HealthType.maintenance
    @Bindable var model: HealthModel
    
    @State var isAdaptive: Bool = false

    init(_ model: HealthModel) {
        self.model = model
    }

    var body: some View {
//        Section(footer: footer) {
        Section {
            VStack {
                picker
                /// Conditionally show the bottom row, only if we have the value, so that we don't get shown the default source values for a split second during the removal animations.
                if model.health.hasType(type) {
                    bottomRow
                } else {
                    EmptyView()
                }
            }
        }
        .onAppear(perform: appeared)
        .onChange(of: isAdaptive, isAdaptiveChanged)
    }
    
    func isAdaptiveChanged(old: Bool, new: Bool) {
        model.maintenanceEnergyIsAdaptive = new
    }
    
    func appeared() {
        setIsAdaptive()
    }
    
    var footer: some View {
        Text(HealthType.maintenance.reason!)
    }

    func setIsAdaptive() {
        withAnimation {
            isAdaptive = switch (model.health.hasCalculatedMaintenance, model.health.hasEstimatedMaintenance) {
            case (true, true):  model.maintenanceEnergyIsAdaptive
            case (true, false):     true    /// adaptive
            case (false, true):     false   /// estimated
            case (false, false):    true    /// adaptive
            }
        }
    }
    
    var picker: some View {
        var disabled: Bool {
            !model.health.hasCalculatedAndEstimatedMaintenance
        }
        
        let selection = Binding<Bool>(
            get: {
                switch (model.health.hasCalculatedMaintenance, model.health.hasEstimatedMaintenance) {
                case (true, true):  model.maintenanceEnergyIsAdaptive
                case (true, false):     true    /// adaptive
                case (false, true):     false   /// estimated
                case (false, false):    true    /// adaptive
                }
            },
            set: {
                model.maintenanceEnergyIsAdaptive = $0
            }
        )
        
//        return Picker("", selection: selection) {
        return Picker("", selection: $isAdaptive) {
            Text("Adaptive").tag(true)
            Text("Estimated").tag(false)
        }
        .pickerStyle(.segmented)
        .disabled(disabled)
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
        model.health.isUsingCalculatedMaintenance
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
        case .maintenance:
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
        
        @ViewBuilder
        var valueContent: some View {
            if let value {
                LargeHealthValue(
                    value: value,
                    valueString: value.formattedEnergy,
                    unitString: "\(settingsStore.energyUnit.abbreviation) / day"
                )
            } else {
                Text("Not Set")
                    .foregroundStyle(.secondary)
            }
        }
        
        var loadingContent: some View {
            ProgressView()
                .fixedSize(horizontal: true, vertical: false)
        }
        
        var value: Double? {
            if model.maintenanceEnergyIsAdaptive,
               let value = model.health.maintenance?.adaptive.value,
               model.health.maintenance?.adaptive.error == nil
            {
                EnergyUnit.kcal.convert(value, to: settingsStore.energyUnit)
            } else if let value = model.health.estimatedMaintenance(in: settingsStore.energyUnit) {
                value
            } else {
                nil
            }
        }
        
        @ViewBuilder
        var content: some View {
            if !model.health.isUsingCalculatedMaintenance {
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
        
        return ZStack(alignment: .bottomTrailing) {
//            content
            valueContent
            LargePlaceholderText
                .opacity(0)
        }
    }
}

#Preview {
    NavigationStack {
        HealthSummary(model: MockCurrentHealthModel)
            .environment(SettingsStore.shared)
    }
}

