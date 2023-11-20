import SwiftUI
import PrepShared

/// [ ] Design the Energy Expenditure cell for when we don't have enough weight data
/// [ ] Consider having another tag below the one for Calculated/Estimated and have it say the message, e.g. "Insufficient weight data" or "Insufficient food data"
/// [ ] If user taps this tag, pop up a small message elaborating (e.g. "You need to have at least [2 weight measurements/1 day with food logged] over the [past two weeks/two weeks prior] to calculate your expenditure."

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

/**
 Energy burn algorithm:
 
 getWeightMovingAverage(from date: Date, in unit: WeightUnit = .kg) -> Double?
 1. Fetch all weights for the past week from the date provided (including it)
     - Fetch from our backend, getting HealthDetails for each Day
     - Fail if we have 0 entires
 2. For each day, calculate average daily weight (average out any values on that day)
 3. Now get the moving average for the weight by averaging out the daily values

 getTotalConsumedCalories(from date: Date, in unit: EnergyUnit = .kcal) -> Double?
 1. Fetch consumed calories over the past week from the date provided (not including it)
     - Fetch from our backend, getting the energyInKcals for each Day
     - Fail if we have 0 entires
 2. If we have less than 7 values, get the average and use this for the missing days
 3. Sum all the day's values

 calculateEnergyBurn(for date: Date, in unit: EnergyUnit = .kcal) -> Result<Double, EnergyBurnError>
 1. weightDelta = getWeightMovingAverage(from: date) - getWeightMovingAverage(from: date-7days)
 2. Convert to pounds, then convert to weightDeltaInCalories using 1lb = 3500 kcal
 3. calories = getTotalConsumedCalories(from: date)
 4. Now burn = calories - weightDelta
 5. If we had an error, it would have been weightDelta or calories not being calculable because of not having at least 1 entry in the window

 */

public struct TDEEEstimateForm: View {
    @Bindable var model: HealthModel
    
    public init(_ model: HealthModel) {
        self.model = model
    }
    
    public var body: some View {
        Form {
            estimateSection
//                .listSectionSpacing(0)
            symbol("=")
//                .listSectionSpacing(0)
            RestingEnergySection(model: model)
//                .listSectionSpacing(0)
            symbol("+")
//                .listSectionSpacing(0)
            ActiveEnergySection(model: model)
//                .listSectionSpacing(0)
        }
//        .navigationTitle("Estimated Energy Expenditure")
//        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Maintenance Energy")
    }
    
    func symbol(_ string: String) -> some View {
        Text(string)
            .frame(maxWidth: .infinity, alignment: .center)
            .font(.system(.title, design: .rounded, weight: .semibold))
            .foregroundColor(.secondary)
            .listRowBackground(EmptyView())
    }
    
    var estimateSection: some View {
        Section {
            HStack {
                Text("Estimated")
                Spacer()
                EnergyBurnEstimateText(model)
            }
        }
    }
}

struct EnergyBurnEstimateText: View {
    @Bindable var model: HealthModel
    
    init(_ model: HealthModel) {
        self.model = model
    }
    
    var value: Double? {
        model.health.estimatedMaintenance
    }

    @ViewBuilder
    var body: some View {
        if let requiredString = model.health.tdeeRequiredString {
            Text(requiredString)
                .foregroundStyle(Color(.tertiaryLabel))
        } else if let value {
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
        } else {
            EmptyView()
        }
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
//                .listSectionSpacing(0)
//            Color.clear
//                .listRowBackground(EmptyView())
            estimateSection
//                .listSectionSpacing(0)
//            symbol("=")
//                .listSectionSpacing(0)
//            RestingSection(model: model)
//                .listSectionSpacing(0)
//            symbol("+")
//                .listSectionSpacing(0)
//            ActiveSection(model: model)
//                .listSectionSpacing(0)
//            adaptiveSection
        }
    }
    
    var health: Health {
        model.health
    }
    
    var estimateSection: some View {
        @ViewBuilder
        var footer: some View {
            if model.maintenanceEnergyIsAdaptive {
                Text("Used when there isn't sufficient weight or nutrition data to make a calculation.")
            }
        }
        
        return Section(footer: footer) {
            NavigationLink {
                TDEEEstimateForm(model)
            } label: {
                HStack {
                    Text("Estimated")
                    Spacer()
                    EnergyBurnEstimateText(model)
                }
            }
        }
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
        
        var adaptiveRow: some View {
            HStack {
                Text("Use Adaptive Calculation")
                    .layoutPriority(1)
                Spacer()
                Toggle("", isOn: $model.maintenanceEnergyIsAdaptive)
            }
        }
        
        var footer: some View {
//            Text("Your \(HealthType.maintenanceEnergy.abbreviation) is used in energy goals, when targeting a desired weight change.")
            Text(HealthType.maintenanceEnergy.reason!)
        }

        var adaptiveFooter: some View {
            Text("Adaptively calculate your \(HealthType.maintenanceEnergy.abbreviation) based on your weight change and dietary energy over the prior week. [Learn More.](https://example.com)")
        }

        return Group {
            Section(footer: footer) {
                MaintenanceEnergyRow(model)
            }
            Section(footer: adaptiveFooter) {
                adaptiveRow
            }
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
                if let maintenanceEnergy = health.estimatedMaintenance {
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

struct ActiveEnergySection: View {

    @Bindable var model: HealthModel

    var body: some View {
        Section(footer: footer) {
            HealthTopRow(type: .activeEnergy, model: model)
            content
        }
    }
    
    var footer: some View {
        Text(HealthType.activeEnergy.reason!)
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

struct RestingEnergySection: View {
    
    @Bindable var model: HealthModel
    
    var body: some View {
        Section(footer: footer) {
            HealthTopRow(type: .restingEnergy, model: model)
            content
        }
    }
    
    var footer: some View {
        Text(HealthType.restingEnergy.reason!)
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

struct TagView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let string: String
    let foregroundColor: Color
    let backgroundColor: Color?
    let fontWeight: Font.Weight
    
    init(
        string: String,
        foregroundColor: Color = Color(.secondaryLabel),
        backgroundColor: Color? = nil,
        fontWeight: Font.Weight = .regular
    ) {
        self.string = string
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.fontWeight = fontWeight
    }
    
    var body: some View {
        Text(string)
            .foregroundStyle(foregroundColor)
            .font(.footnote)
            .fontWeight(fontWeight)
            .padding(.vertical, 3)
            .padding(.horizontal, 5)
            .background(RoundedRectangle(cornerRadius: 6)
                .fill(backgroundColor ?? Color(colorScheme == .dark ? .systemGray4 : .systemGray5)))
    }
}
