import SwiftUI
import PrepShared

struct HealthWeightSections: View {
    
    @Bindable var settingsStore: SettingsStore
    @Bindable var model: HealthModel
    var focusedType: FocusState<HealthType?>.Binding
    
    init(
        _ model: HealthModel,
        _ settingsStore: SettingsStore,
        _ focusedType: FocusState<HealthType?>.Binding
    ) {
        self.model = model
        self.settingsStore = settingsStore
        self.focusedType = focusedType
    }

    var body: some View {
        valueSection
        sourceSection
//        errorSection
        averageEntriesSection
    }
    
    var averageEntriesSection: some View {
        Section(
            header: Text("1 Dec 2021"),
            footer: Text("The average of these values is being used")
        ) {
            HStack {
                Text("9:53 am")
                Spacer()
                Text("95.7 kg")
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text("2:32 pm")
                Spacer()
                Text("96.3 kg")
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    var sourceSection: some View {
        Group {
            PickerSection($model.weightSource)
//            Section("Use Apple Health's Latest") {
            Section(footer: Text("Use the average of the values for the latest day when available.")) {
                HStack {
                    Text("Use average for day")
                    Spacer()
                    Toggle("", isOn: .constant(true))
                }
            }
//            Section {
//                HStack {
//                    Image(systemName: "checkmark")
//                        .foregroundStyle(Color.accentColor)
//                        .opacity(0)
////                    Text("Entry")
//                    Text("Latest Entry")
//                    Spacer()
//                    Text("95.7 kg")
//                        .foregroundStyle(.secondary)
//                }
//                HStack {
//                    Image(systemName: "checkmark")
//                        .foregroundStyle(Color.accentColor)
////                        .opacity(0)
////                    Text("Day's Average")
//                    Text("Latest Day Average")
//                    Spacer()
//                    Text("95.4 kg")
//                        .foregroundStyle(.secondary)
//                }
//            }
        }
    }
    
    var valueSection: some View {
        var valueRow: some View {
            HStack {
                Text("Weight")
                Spacer()
                if let weight = model.health.weight {
                    switch weight.source {
                    case .healthKit:
//                        Text("95.7 kg")
                        Text("95.4 kg")
                            .foregroundStyle(.secondary)
//                        healthValue
                    case .userEntered:
                        manualValue
                    }
                }
            }
        }
        
        var dateRow: some View {
            HStack {
                Text("Date")
                Spacer()
//                Text("Yesterday, 9:08 pm")
//                Text("Yesterday's Average")
                Text("1 Dec 2021")
//                Text("1 Dec 2021, 9:08 pm")
                    .foregroundStyle(.secondary)
            }
        }
        
        var averagedEntriesRow: some View {
            HStack {
                Text("Averaged Entries")
                Spacer()
                Text("3")
                    .foregroundStyle(.secondary)
            }
        }
        
        return Section {
            valueRow
            dateRow
//            averagedEntriesRow
        }
    }

    var healthValue: some View {
        CalculatedBodyMassView(
            unit: $settingsStore.bodyMassUnit,
            quantityInKg: $model.health.weightQuantity,
            source: model.weightSource
        )
    }
     
    var manualValue: some View {
        BodyMassField(
            unit: $settingsStore.bodyMassUnit,
            valueInKg: $model.weightValue,
            focusedType: focusedType,
            healthType: .weight
        )
    }
    
    //MARK: - Legacy

    @ViewBuilder
    var valueRow: some View {
        if let weight = model.health.weight {
            HStack {
                Spacer()
                if model.isSettingTypeFromHealthKit(.weight) {
                    ProgressView()
                } else {
                    switch weight.source {
                    case .healthKit:
                        healthValue
                    case .userEntered:
                        manualValue
                    }
                }
            }
        }
    }
    var body_ : some View {
        Section(footer: footer) {
            HealthTopRow(type: .weight, model: model)
            valueRow
            healthKitErrorCell
        }
    }
    
    var footer: some View {
        HealthFooter(
            source: model.weightSource,
            type: .weight,
            hasQuantity: model.health.weightQuantity != nil
        )
    }
    
    @ViewBuilder
    var healthKitErrorCell: some View {
        if model.shouldShowHealthKitError(for: .weight) {
            HealthKitErrorCell(type: .weight)
        }
    }
}

#Preview {
    @FocusState var focusedType: HealthType?
    return NavigationStack {
        Form {
            HealthWeightSections(MockHealthModel, SettingsStore.shared, $focusedType)
        }
    }
}
