import SwiftUI
import PrepShared

struct VariablesSections: View {
    
    @Bindable var provider: Provider
    
    @Binding var variables: Variables
    let date: Date
    @Binding var isPresented: Bool
    let showHeader: Bool
    
    /// The type that the variables are for
    let type: VariablesType
    
    var preferLeanBodyMass: Binding<Bool>?
    
    init(
        type: VariablesType,
        variables: Binding<Variables>,
        preferLeanBodyMass: Binding<Bool>? = nil,
        provider: Provider,
        date: Date,
        isPresented: Binding<Bool>,
        showHeader: Bool = true
    ) {
        self.provider = provider
        self.type = type
        self.preferLeanBodyMass = preferLeanBodyMass
        self.date = date
        self.showHeader = showHeader
        _variables = variables
        _isPresented = isPresented
    }
    
    var body: some View {
        explanation
        leanBodyMassPicker
        nonTemporalSection
        temporalSections
    }
    
    var leanBodyMassPicker: some View {
        
        var shouldShow: Bool {
            variables.isLeanBodyMass
            && preferLeanBodyMass != nil
            && provider.healthDetails.hasIncompatibleLeanBodyMassAndFatPercentageWithWeight
        }
        
        let binding = Binding<Bool>(
            get: { preferLeanBodyMass?.wrappedValue ?? true },
            set: {
                preferLeanBodyMass?.wrappedValue = $0
            }
        )
        
        return Group {
            if shouldShow {
                Section {
                    Picker("Use", selection: binding) {
                        Text("Lean Body Mass").tag(true)
                        Text("Fat Percentage and Weight").tag(false)
                    }
                    .pickerStyle(.menu)
                }
            }
        }
    }
    
    var explanation: some View {
        var header: some View {
            Text(type.title)
                .formTitleStyle()
        }
        
        return Section(header: header) {
            Text(variables.description)
        }
    }
    
    var nonTemporalSection: some View {
        
        func link(for healthDetail: HealthDetail) -> some View {
            NonTemporalVariableLink(
                healthDetail: healthDetail,
                provider: provider,
                date: date,
                isPresented: $isPresented
            )
        }
        
        return Group {
            if !variables.nonTemporal.isEmpty {
//                Section(header: mainHeader) {
                Section {
                    ForEach(variables.nonTemporal) {
                        link(for: $0)
                    }
                }
            }
        }
    }
    
    var temporalSections: some View {
        func section(for healthDetail: HealthDetail, index: Int) -> some View {
            TemporalVariableSection(
                healthDetail: healthDetail,
                provider: provider,
                type: type,
                date: date,
                isPresented: $isPresented,
                shouldShowMainHeader: Binding<Bool>(
                    get: { variables.nonTemporal.isEmpty && index == 0 },
                    set: { _ in }
                ),
                showHeader: showHeader
            )
        }
        
        return Group {
            ForEach(Array(variables.temporal.enumerated()), id: \.offset) { index, healthDetail in
                section(for: healthDetail, index: index)
                
                /// Special case for `.leanBodyMass` where we insert an "or" after the section for lean body mass
                if variables.isLeanBodyMass, healthDetail == .leanBodyMass {
                    Section {
                        HStack {
                            VStack {
                                Divider()
                            }
                            Text("or")
                            VStack {
                                Divider()
                            }
                        }
                        .listRowBackground(EmptyView())
                    }
                    .listSectionSpacing(.compact)
                }
            }
        }
    }
}

import SwiftUI

struct TemporalVariableSection: View {
    
    let healthDetail: HealthDetail
    @Bindable var provider: Provider

    let type: VariablesType
    let date: Date
    @Binding var isPresented: Bool
    @Binding var shouldShowMainHeader: Bool
    let showHeader: Bool

    @State var hasPushedForm = false
    @State var replacements: HealthDetails.ReplacementsForMissing?
    @State var newReplacements: HealthDetails.ReplacementsForMissing? = nil

    init(
        healthDetail: HealthDetail,
        provider: Provider,
        type: VariablesType,
        date: Date,
        isPresented: Binding<Bool>,
        shouldShowMainHeader: Binding<Bool>,
        showHeader: Bool
    ) {
        self.healthDetail = healthDetail
        self.provider = provider
        self.type = type
        self.date = date
        _isPresented = isPresented
        _shouldShowMainHeader = shouldShowMainHeader
        self.showHeader = showHeader
        _replacements = State(initialValue: provider.healthDetails.replacementsForMissing)
    }

    var body: some View {
        Section(header: header, footer: footer) {
            pastLink
            currentLink
        }
        .onChange(of: provider.healthDetails.replacementsForMissing, replacementsChanged)
    }
    
    func replacementsChanged(old: HealthDetails.ReplacementsForMissing, new: HealthDetails.ReplacementsForMissing) {
        if hasPushedForm {
            newReplacements = new
        } else {
            newReplacements = nil
            withAnimation {
                replacements = new
            }
        }
    }
    
    func formDisappeared() {
        withAnimation {
            replacements = newReplacements
        }
        newReplacements = nil
        hasPushedForm = false
    }
    
    func formAppeared() {
        hasPushedForm = true
    }
    
    @ViewBuilder
    var pastLink: some View {
        if !provider.healthDetails.hasSet(healthDetail) {
            switch healthDetail {
            case .weight:           pastWeight
            case .leanBodyMass:     pastLeanBodyMass
            case .height:           pastHeight
            case .preganancyStatus: pastPregnancyStatus
            case .fatPercentage:    pastFatPercentage
            case .maintenance:      pastMaintenance
            default:                EmptyView()
            }
        }
    }
    
    var currentLink: some View {
        
        var dateString: String {
            if date.isToday {
                "Today"
            } else {
                date.shortDateString
            }
        }
        
        return NavigationLink {
            Group {
                switch healthDetail {
                case .height:
                    HeightForm(
                        provider: provider,
                        isPresented: $isPresented
                    )
                case .weight:
                    WeightForm(
                        provider: provider,
                        isPresented: $isPresented
                    )
                case .leanBodyMass:
                    LeanBodyMassForm(
                        provider: provider,
                        isPresented: $isPresented
                    )
                case .preganancyStatus:
                    PregnancyStatusForm(
                        provider: provider,
                        isPresented: $isPresented
                    )
                case .fatPercentage:
                    FatPercentageForm(
                        provider: provider,
                        isPresented: $isPresented
                    )
                case .maintenance:
                    MaintenanceForm(
                        provider: provider,
                        isPresented: $isPresented
                    )
                default:
                    EmptyView()
                }
            }
            .onDisappear(perform: formDisappeared)
            .onAppear(perform: formAppeared)
        } label: {
            HStack {
                Text(dateString)
                Spacer()
                if provider.healthDetails.hasSet(healthDetail)  {
                    Text(provider.healthDetails.valueString(for: healthDetail, provider))
                } else {
                    Text(NotSetString)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    @ViewBuilder
    var pastWeight: some View {
        if let dated = replacements?.datedWeight {
            NavigationLink {
                WeightForm(
                    date: dated.date,
                    weight: dated.weight,
                    provider: provider,
                    isPresented: $isPresented,
                    save: { newWeight in
                        provider.updateLatestWeight(newWeight)
                    }
                )
                .onAppear(perform: formAppeared)
                .onDisappear(perform: formDisappeared)
            } label: {
                HStack {
                    Text(dated.date.shortDateString)
                    Spacer()
                    Text(dated.weight.valueString(in: provider.bodyMassUnit))
                }
            }
        }
    }
    
    @ViewBuilder
    var pastLeanBodyMass: some View {
        if let dated = replacements?.datedLeanBodyMass {
            NavigationLink {
                LeanBodyMassForm(
                    date: dated.date,
                    leanBodyMass: dated.leanBodyMass,
                    provider: provider,
                    isPresented: $isPresented,
                    save: { leanBodyMass in
                        provider.updateLatestLeanBodyMass(leanBodyMass)
                    }
                )
                .onAppear(perform: formAppeared)
                .onDisappear(perform: formDisappeared)
            } label: {
                HStack {
                    Text(dated.date.shortDateString)
                    Spacer()
                    Text(dated.leanBodyMass.valueString(in: provider.bodyMassUnit))
                }
            }
        }
    }
    
    @ViewBuilder
    var pastFatPercentage: some View {
        if let dated = replacements?.datedFatPercentage {
            NavigationLink {
                FatPercentageForm(
                    date: dated.date,
                    fatPercentage: dated.fatPercentage,
                    provider: provider,
                    isPresented: $isPresented,
                    save: { fatPercentage in
                        provider.updateLatestFatPercentage(fatPercentage)
                    }
                )
                .onAppear(perform: formAppeared)
                .onDisappear(perform: formDisappeared)
            } label: {
                HStack {
                    Text(dated.date.shortDateString)
                    Spacer()
                    Text(dated.fatPercentage.valueString)
                }
            }
        }
    }
    
    @ViewBuilder
    var pastMaintenance: some View {
        if let dated = replacements?.datedMaintenance {
            NavigationLink {
                MaintenanceForm(
                    date: dated.date,
                    maintenance: dated.maintenance,
                    provider: provider,
                    isPresented: $isPresented,
                    saveHandler: { maintenance, shouldResync in
                        provider.updateLatestMaintenance(maintenance)
                    }
                )
                .onAppear(perform: formAppeared)
                .onDisappear(perform: formDisappeared)
            } label: {
                HStack {
                    Text(dated.date.shortDateString)
                    Spacer()
                    Text(dated.maintenance.valueString(in: provider.energyUnit))
                }
            }
        }
    }
    
    @ViewBuilder
    var pastPregnancyStatus: some View {
        if let dated = replacements?.datedPregnancyStatus {
            NavigationLink {
                PregnancyStatusForm(
                    date: dated.date,
                    pregnancyStatus: dated.pregnancyStatus,
                    isPresented: $isPresented,
                    save: { pregnancyStatus in
                        provider.updateLatestPregnancyStatus(pregnancyStatus)
                    }
                )
                .onAppear(perform: formAppeared)
                .onDisappear(perform: formDisappeared)
            } label: {
                HStack {
                    Text(dated.date.shortDateString)
                    Spacer()
                    Text(dated.pregnancyStatus.name)
                }
            }
        }
    }
    
    @ViewBuilder
    var pastHeight: some View {
        if let dated = replacements?.datedHeight {
            NavigationLink {
                HeightForm(
                    date: dated.date,
                    height: dated.height,
                    provider: provider,
                    isPresented: $isPresented,
                    save: { newHeight in
                        provider.updateLatestHeight(newHeight)
                    }
                )
                .onAppear(perform: formAppeared)
                .onDisappear(perform: formDisappeared)
            } label: {
                HStack {
                    Text(dated.date.shortDateString)
                    Spacer()
                    Text(dated.height.valueString(in: provider.heightUnit))
                }
            }
        }
    }
    
    
    //MARK: - Accessory Views

    var header: some View {
        Text(healthDetail.name)
    }
    
    var footer: some View {
        var string: String? {
            guard !provider.healthDetails.hasSet(healthDetail) else {
                return nil
            }
            if hasLatestDetail {
                let dateString: String
                let suffix: String
                if !date.isToday {
                    dateString = date.shortDateString
                    suffix = "prior to that "
                } else {
                    dateString = "today"
                    suffix = ""
                }
                return "Since no \(healthDetail.name.lowercased()) data has been set for \(dateString), the most recent entry \(suffix)is being used."
            } else {
                return nil
            }
        }
        
        return Group {
            if let string {
                Text(string)
            }
        }
    }

    var hasLatestDetail: Bool {
        provider.healthDetails.replacementsForMissing.has(healthDetail)
    }
}

import SwiftUI

struct NonTemporalVariableLink: View {
    
    let healthDetail: HealthDetail
    @Bindable var provider: Provider
    let date: Date
    @Binding var isPresented: Bool

    var body: some View {
        NavigationLink {
            form
        } label: {
            label
        }
    }
    
    @ViewBuilder
    var form: some View {
        switch healthDetail {
        case .age:
            AgeForm(
                provider: provider,
                isPresented: $isPresented
            )
        case .biologicalSex:
            BiologicalSexForm(
                provider: provider,
                isPresented: $isPresented
            )
        case .smokingStatus:
            SmokingStatusForm(
                provider: provider,
                isPresented: $isPresented
            )
        default:
            EmptyView()
        }
    }
    
    var label: some View {
        HStack {
            Text(healthDetail.name)
            Spacer()
            Text(provider.healthDetails.valueString(
                for: healthDetail,
                provider
            ))
            .foregroundStyle(provider.healthDetails.hasSet(healthDetail)
                             ? .primary : .secondary
            )
        }
    }
}

struct RestingEnergyEquationVariablesSectionsPreview: View {
    
    @State var provider: Provider? = nil
    @State var equation: RestingEnergyEquation = .katchMcardle
//    @State var variables: Variables = RestingEnergyEquation.cunningham.variables
    
    @State var preferLeanBodyMass: Bool = false
    
    @ViewBuilder
    var body: some View {
        if let provider {
            NavigationView {
                Form {
                    Section(header: Text("Equation")) {
                        Picker("", selection: $equation) {
                            ForEach(RestingEnergyEquation.allCases, id: \.self) {
                                Text($0.name).tag($0)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                    VariablesSections(
                        type: .equation,
                        variables: Binding<Variables>(
                            get: { equation.variables },
                            set: { _ in }
                        ),
                        preferLeanBodyMass: Binding<Bool>(
                            get: { preferLeanBodyMass },
                            set: { newValue in
                                self.preferLeanBodyMass = newValue
                            }
                        ),
                        provider: provider,
                        date: provider.healthDetails.date,
                        isPresented: .constant(true),
                        showHeader: true
                    )
                }
            }
        } else {
            Color.clear
                .task {
//                    var healthDetails = await fetchOrCreateHealthDetailsFromBackend(Date.now)
                    var healthDetails = HealthDetails(date: Date.now)
                    healthDetails.weight = .init(
                        weightInKg: 95,
                        measurements: [.init(date: Date.now, weightInKg: 95)]
                    )
                    healthDetails.leanBodyMass = .init(
                        leanBodyMassInKg: 69,
                        measurements: [.init(date: Date.now, leanBodyMassInKg: 69, source: .manual, healthKitUUID: nil)]
                    )
                    healthDetails.fatPercentage = .init(
                        fatPercentage: 20,
                        measurements: [.init(date: Date.now, percent: 20, source: .manual, healthKitUUID: nil)]
                    )
                    let provider = Provider()
                    provider.healthDetails = healthDetails
                    await MainActor.run {
                        self.provider = provider
                    }
                }
        }
    }
}
#Preview("Resting") {
    RestingEnergyEquationVariablesSectionsPreview()
}

struct LeanBodyMassEquationVariablesSectionsPreview: View {
    
    @State var provider: Provider? = nil
    @State var equation: LeanBodyMassAndFatPercentageEquation = .boer
//    @State var variables: Variables = RestingEnergyEquation.cunningham.variables
    
    @ViewBuilder
    var body: some View {
        if let provider {
            NavigationView {
                Form {
                    Section(header: Text("Equation")) {
                        Picker("", selection: $equation) {
                            ForEach(LeanBodyMassAndFatPercentageEquation.allCases, id: \.self) {
                                Text($0.name).tag($0)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                    VariablesSections(
                        type: .equation,
                        variables: Binding<Variables>(
                            get: { equation.variables },
                            set: { _ in }
                        ),
                        provider: provider,
                        date: provider.healthDetails.date,
                        isPresented: .constant(true),
                        showHeader: true
                    )
                }
            }
        } else {
            Color.clear
                .task {
                    var healthDetails = await Provider.fetchOrCreateHealthDetailsFromBackend(Date.now)
                    healthDetails.weight = .init(
                        weightInKg: 95,
                        measurements: [.init(date: Date.now, weightInKg: 95)]
                    )
                    let provider = Provider()
                    provider.healthDetails = healthDetails
                    await MainActor.run {
                        self.provider = provider
                    }
                }
        }
    }
}
#Preview("Lean Body Mass") {
    LeanBodyMassEquationVariablesSectionsPreview()
}

struct GoalVariablesSectionsPreview: View {
    
    @State var provider: Provider? = nil
    
    @ViewBuilder
    var body: some View {
        if let provider {
            NavigationView {
                Form {
                    VariablesSections(
                        type: .goal,
                        variables: Binding<Variables>(
                            get: { .required([.maintenance], "Your Maintenance Energy is required for this goal.") },
                            set: { _ in }
                        ),
                        provider: provider,
                        date: provider.healthDetails.date,
                        isPresented: .constant(true),
                        showHeader: true
                    )
                }
            }
        } else {
            Color.clear
                .task {
                    var healthDetails = await Provider.fetchOrCreateHealthDetailsFromBackend(Date.now)
                    healthDetails.weight = .init(
                        weightInKg: 95,
                        measurements: [.init(date: Date.now, weightInKg: 95)]
                    )
                    healthDetails.replacementsForMissing = .init(
                        datedMaintenance: .init(
                            date: Date.now.moveDayBy(-1),
                            maintenance: .init(
                                type: .estimated,
                                kcal: 2000,
                                adaptive: .init(),
                                estimate: .init(
                                    kcal: 2000,
                                    restingEnergy: HealthDetails.Maintenance.Estimate.RestingEnergy(
                                        kcal: 1800,
                                        source: .manual
                                    ),
                                    activeEnergy: HealthDetails.Maintenance.Estimate.ActiveEnergy(
                                        kcal: 200,
                                        source: .manual
                                    )
                                ),
                                useEstimateAsFallback: false
                            )
                        )
                    )
                    let provider = Provider()
                    provider.healthDetails = healthDetails
                    await MainActor.run {
                        self.provider = provider
                    }
                }
        }
    }
}
#Preview("Goal") {
    GoalVariablesSectionsPreview()
}

struct DailyValueVariablesSectionsPreview: View {
    
    @State var provider: Provider? = nil
    
    @ViewBuilder
    var body: some View {
        if let provider {
            NavigationView {
                Form {
                    VariablesSections(
                        type: .dailyValue,
                        variables: Binding<Variables>(
                            get: { .required([.smokingStatus], "Your Smoking Status is required to pick a recommended daily value for Magnesium.") },
                            set: { _ in }
                        ),
                        provider: provider,
                        date: provider.healthDetails.date,
                        isPresented: .constant(true),
                        showHeader: true
                    )
                }
            }
        } else {
            Color.clear
                .task {
                    var healthDetails = await Provider.fetchOrCreateHealthDetailsFromBackend(Date.now)
                    healthDetails.weight = .init(
                        weightInKg: 95,
                        measurements: [.init(date: Date.now, weightInKg: 95)]
                    )
                    let provider = Provider()
                    provider.healthDetails = healthDetails
                    await MainActor.run {
                        self.provider = provider
                    }
                }
        }
    }
}
#Preview("Daily Value") {
    DailyValueVariablesSectionsPreview()
}

#Preview("Demo") {
    SettingsDemoView()
}

