import SwiftUI
import PrepShared

/// [ ] Add footer for when HealthKit values aren't available

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
        .navigationTitle("Energy Expenditure")
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
                Text("Estimate")
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
        model.health.estimatedEnergyBurn
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
            if model.energyBurnIsCalculated {
                Text("Used when there isn't sufficient weight or nutrition data to make a calculation.")
            }
        }
        
        return Section(footer: footer) {
            NavigationLink {
                TDEEEstimateForm(model)
            } label: {
                HStack {
                    Text("Estimate")
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
                Toggle("", isOn: $model.energyBurnIsCalculated)
            }
        }
        
        var footer: some View {
            Text("Your \(HealthType.energyBurn.abbreviation) is used in energy goals, when targeting a desired weight change.")
        }

        var adaptiveFooter: some View {
            Text("Continuously calculate your \(HealthType.energyBurn.abbreviation) based on your weight change and food intake over the past week. [Learn More.](https://example.com)")
        }

        return Group {
            Section(footer: footer) {
                EnergyBurnRow(model)
//                HealthTopRow(type: .energyBurn, model: model)
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
                        model.remove(.energyBurn)
                    }
                }
                .textCase(.none)
            }
        }
        
        var footer: some View {
            Text(HealthType.energyBurn.reason!)
        }
        
        return Section(header: header) {
            if let requiredString = health.tdeeRequiredString {
                Text(requiredString)
                    .foregroundStyle(Color(.tertiaryLabel))
            } else {
                if let maintenanceEnergy = health.estimatedEnergyBurn {
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

#Preview {
    NavigationView {
        HealthSummary(model: MockHealthModel)
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

struct EnergyBurnRow: View {
    
    let type = HealthType.energyBurn
    @Bindable var model: HealthModel
    
    init(_ model: HealthModel) {
        self.model = model
    }
    
    var body: some View {
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
    
    var topRow: some View {
        HStack(alignment: verticalAlignment) {
            removeButton
            Text(type.name)
                .fontWeight(.semibold)
            Spacer()
        }
    }
    
    var bottomRow: some View {
        HStack(alignment: .top) {
            calculatedTag
            Spacer()
            detail
                .multilineTextAlignment(.trailing)
        }
    }
    
    var calculatedTag: some View {
        var string: String {
            if model.energyBurnIsCalculated {
                "Calculated"
            } else {
                "Estimated"
            }
        }
        
        var foregroundColor: Color {
            Color(model.energyBurnIsCalculated ? .white : .secondaryLabel)
        }
        
        var backgroundColor: Color {
            model.energyBurnIsCalculated ? Color.accentColor : Color(.systemBackground)
        }
        
        var fontWeight: Font.Weight {
            model.energyBurnIsCalculated ? .semibold : .regular
        }
        
        return Text(string)
            .foregroundStyle(foregroundColor)
            .font(.footnote)
            .fontWeight(fontWeight)
            .padding(.vertical, 3)
            .padding(.horizontal, 5)
            .background(RoundedRectangle(cornerRadius: 6)
                .fill(backgroundColor))
    }
    
    var verticalAlignment: VerticalAlignment {
        switch type {
        case .energyBurn:
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
        
        func valueContent(_ value: Double) -> some View {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value.formattedEnergy)
                    .animation(.default, value: value)
                    .contentTransition(.numericText(value: value))
//                    .font(.system(.body, design: .monospaced, weight: .bold))
                    .font(.system(.largeTitle, design: .monospaced, weight: .bold))
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
        
        var value: Double? {
            if model.energyBurnIsCalculated, let value = model.energyBurnCalculatedValue {
                return value
            } else {
                return model.health.estimatedEnergyBurn
            }
        }
        
        @ViewBuilder
        var content: some View {
            if model.isSettingMaintenanceFromHealthKit {
                loadingContent
            } else if let message = model.health.tdeeRequiredString {
                emptyContent(message)
            } else if let value {
                valueContent(value)
            } else {
                EmptyView()
            }
        }
        
        return ZStack(alignment: .trailing) {
            content
            valueContent(0)
                .opacity(0)
        }
    }
}
