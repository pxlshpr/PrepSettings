import SwiftUI
import PrepShared

/// [ ] Create a type for the use of this form, being either the main Health.weight one, a Weight Sample or a Weight Data point or something?
/// [ ] When showing the weight data point thing, give the option to use average of past x interval, which should include the section with the links to the Weight Sample forms
/// [ ] When loading form, load the data from HealthKit based on the type
/// [ ] For standard use, load the latest weight data, getting all values for the day
/// [ ] For data point use, load the weight data on that day (do whatever we're doing currently)
/// [ ] For sample use, load the weight data on that day itself (all the values)
/// [ ] Make sure we're showing the values correctly
/// [ ] Make sure changes are saved in real time in the backend
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

    @State var isWeightSample = false
    
    var body: some View {
        sourceSection
        dateSection
        averageSection
        averageEntriesSection
        valueSection
    }
    
    var dateSection: some View {
        var footer: some View {
            Text("This is the most recent date with weight data in Apple Health.")
        }
        
        var section: some View {
            Section(footer: footer) {
                HStack {
                    Text("Date")
                    Spacer()
//                    Text("Yesterday, 9:08 pm")
//                    Text("Yesterday's Average")
                    Text("1 Dec 2021")
//                    Text("1 Dec 2021, 9:08 pm")
                        .foregroundStyle(.secondary)
                }
            }
        }
        
        return Group {
            if !isWeightSample {
                section
            }
        }
    }
    
    var averageEntriesSection: some View {
        Section(
//            header: Text("1 Dec 2021"),
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
    
    var averageSection: some View {
        Section(footer: Text("Use the average when multiple values for the day are available.")) {
            HStack {
                Text("Use day's average")
                Spacer()
                Toggle("", isOn: .constant(true))
            }
        }
    }
    
    var sourceSection: some View {
        PickerSection($model.weightSource)
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
        
        var averagedEntriesRow: some View {
            HStack {
                Text("Averaged Entries")
                Spacer()
                Text("3")
                    .foregroundStyle(.secondary)
            }
        }
        
        return Section {
//            dateRow
            valueRow
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
        .navigationTitle("Weight")
        .navigationBarTitleDisplayMode(.inline)
    }
}
