import SwiftUI
import PrepShared

public enum AdaptiveDataSection: Int, Hashable, Codable, CaseIterable {
    case summary = 1
    case weight
    case dietaryEnergy
}

public extension AdaptiveDataSection {
    var name: String {
        switch self {
        case .summary:          "Summary"
        case .weight:           "Weight"
        case .dietaryEnergy:    "Dietary Energy"
        }
    }
}

struct AdaptiveDataList: View {
    
    @State var section: AdaptiveDataSection = .summary
    @State var useMovingAverageForWeight = true
    @State var showingWeightConversionInfo = false

    var body: some View {
        list
            .navigationTitle("Maintenance Energy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .navigationBarBackButtonHidden(isEditing)
    }
    
    var list: some View {
        List {
            content
        }
    }
    
    @ViewBuilder
    var content: some View {
        daysSection
        if !isEditing {
            weightSection
            dietaryEnergySection
            calculationSections
        }
    }
    
    var weightSection: some View {
        var footer: some View {
            VStack(alignment: .leading, spacing: 5) {
                Text("Change in your weight over the prior 7 days, converted to energy.")
                Button("Learn More") {
                    showingWeightConversionInfo = true
                }
                .font(.footnote)
            }
            .sheet(isPresented: $showingWeightConversionInfo) {
                NavigationStack {
                    Form {
                        Text("The conversion is done using the old research that 1 lb of body fat equals 3500 kcal.")
                        Text("This is no longer considered accurate, and you usually lose a mix of fat, lean tissue and water.")
                        Text("We are still using this value as it's the best estimation we have to be able to make a calculation.")
                        Text("If you consume a certain amount based on that calculation, and your weight change isn't what you desire it to be—you could keep amending the deficit or surplus until your desired weight change is achieved.")
                        Text("Other factors like inaccuracies in logging your food could also contribute to a less accurate calculation—which is why having this calculation periodically adapt to your observed weight change is more useful than getting it precisely correct.")
                        Text("Also, as your weight change plateaus, this conversion would be even less relevant since the energy change would be 0 regardless.")
                    }
                    .font(.callout)
                    .navigationTitle("Weight to Energy Conversion")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") {
                                showingWeightConversionInfo = false
                            }
                            .fontWeight(.semibold)
                        }
                    }
                }
                .presentationDetents([.medium, .large])
            }
        }
        
        var header: some View {
            Text("Weight")
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundStyle(Color(.label))
                .textCase(.none)
        }

        return Group {
            Section(header: header, footer: footer) {
                NavigationLink {
                    Form {
                        Section("Kilograms") {
                            ForEach([0, 6], id: \.self) {
                                cell(daysAgo: $0, component: .weight)
                            }
                        }
//                        Section(footer: movingAverageFooter) {
//                            HStack {
//                                Toggle("Use Moving Average", isOn: $useMovingAverageForWeight)
//                            }
//                        }
                        fillAllFromHealthAppSection
                    }
                    .navigationTitle("Weight")
                } label: {
                    Text("Show All Data")
                }
                HStack {
                    Text("Weight Change")
                    Spacer()
                    Text("- 0.69 kg")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Equivalent Energy")
                    Spacer()
                    Text("- 5,291 kcal")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    var daysSection: some View {
        Section(footer: Text("Days over which to calculate your maintenance energy.")) {
            HStack {
                Text("Number of days")
                Spacer()
                Text("7")
                    .foregroundStyle(isEditing ? Color.accentColor : Color.primary)
            }
        }
    }
    
    var dietaryEnergySection: some View {
        
        var header: some View {
            Text("Dietary Energy")
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundStyle(Color(.label))
                .textCase(.none)
        }
        
        var footer: some View {
            Text("The energy you consumed over the 7 days leading up to this date.")
        }
        
        return Section(header: header, footer: footer) {
            NavigationLink {
                Form {
                    Section("Kilocalories") {
                        ForEach(0...6, id: \.self) {
                            cell(daysAgo: $0, component: .dietaryEnergy)
                        }
                    }
                    fillAllFromHealthAppSection
                }
                .navigationTitle("Dietary Energy")
            } label: {
                Text("Show All Data")
            }
            HStack {
                Text("Total Dietary Energy")
                Spacer()
                Text("22,146 kcal")
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    @ViewBuilder
    var calculationSections: some View {
//        Section(footer: Text("Total energy consumption that would have resulted in no change in weight.")) {
//            HStack {
//                Text("Total Maintenance")
//                Spacer()
//                Text("27,437 kcal")
//                    .foregroundStyle(.secondary)
//            }
//        }
//        Section(footer: Text("Daily energy consumption that would have resulted in no change in weight, ie. your maintenance.")) {
        Section(footer: Text("The energy you would have to consume daily to maintain your weight.")) {
//        Section {
            HStack {
                Text("Maintenance Energy")
                Spacer()
                Text("3,920 kcal")
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    var fillAllFromHealthAppSection: some View {
        Section {
            Button("Fill All from Health app") {
                
            }
        }
    }
    
    var movingAverageFooter: some View {
        Text("Use a 7-day moving average of your weight data when available.\n\nThis makes the calculation less affected by cyclical fluctuations in your weight due to factors like fluid loss.")
    }
    
    //TODO: Next
    /// [x] Store data points in health (2 for weight, and 7 for dietary energy)
    /// [ ] Now write the automatic healthkit fetching code that grabs the values from HealthKit
    /// [ ] Now test the maintenance thing for a date in the past where we have health kit data
    /// [ ] Feed in data points that are stored in health here in the cell
    /// [ ] Let values be nil and if nil, show "Not set" in list itself
    /// [ ] Now complete the form, with bindings for picker and value
    /// [ ] Make sure the data is only saved when the user actually taps on "Save" (simply going back shouldn't save it\
    /// [ ] Add the field in HealthSummary for date (when not today) – but first try showing today as well
    func cell(daysAgo: Int, component: AdaptiveDataComponent) -> some View {
        var dataPoint: AdaptiveDataPoint {
            .init(.userEntered, 0)
        }
        return NavigationLink {
            AdaptiveDataForm(dataPoint, component, Date.now)
        } label: {
            AdaptiveDataCell(dataPoint, Date.now)
        }
    }
    
    @State var isEditing = false
    
    var toolbarContent: some ToolbarContent {
        Group {
//            ToolbarItem(placement: .bottomBar) {
//                Picker("", selection: $section) {
//                    ForEach(AdaptiveDataSection.allCases, id: \.self) {
//                        Text($0.name).tag($0)
//                    }
//                }
//                .pickerStyle(.segmented)
//            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(isEditing ? "Done" : "Edit") {
                    withAnimation {
                        isEditing.toggle()
                    }
                }
                .fontWeight(isEditing ? .semibold : .regular)
            }
            if isEditing {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        isEditing = false
                    }
                }
            }
        }
    }
}

extension Date {
    var adaptiveMaintenanceDateString: String {
//        if isToday {
//            "Today"
//        } else if isYesterday {
//            "Yesterday"
//        } else {
            let formatter = DateFormatter()
            if self.year == Date().year {
                formatter.dateFormat = "d MMM"
            } else {
                formatter.dateFormat = "d MMM yyyy"
            }
            return formatter.string(from: self)
//        }
    }
}

public extension AdaptiveDataType {
    var systemImage: String {
        switch self {
//        case .averaged:     "chart.line.flattrend.xyaxis"
        case .averaged:     "equal"
        case .healthKit:    "heart.fill"
        case .userEntered:  "pencil"
        }
    }
    
    var name: String {
        switch self {
        case .averaged:     "Average value"
        case .healthKit:    "Health app"
        case .userEntered:  "Entered manually"
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .averaged:     .white
        case .healthKit:    .pink
        case .userEntered:  .white
        }
    }

    var backgroundColor: Color {
        switch self {
        case .averaged:     .gray
        case .healthKit:    .white
        case .userEntered:  .accentColor
        }
    }
    
    var strokeColor: Color {
        switch self {
        case .averaged:     .clear
        case .healthKit:    .gray
        case .userEntered:  .clear
        }
    }
}

struct AdaptiveDataCell: View {
    
    let dataPoint: AdaptiveDataPoint
    let date: Date
    
    init(_ dataPoint: AdaptiveDataPoint, _ date: Date) {
        self.dataPoint = dataPoint
        self.date = date
    }
    
    var body: some View {
        HStack {
            image
            Text("\(dataPoint.value.cleanAmount)")
            averageLabel
            Spacer()
            Text(date.adaptiveMaintenanceDateString)
                .foregroundStyle(.secondary)
        }
    }
    
    @ViewBuilder
    var averageLabel: some View {
        if type == .averaged {
            TagView(string: "Average")
        }
    }
    
    var image: some View {
        Image(systemName: type.systemImage)
            .foregroundStyle(type.foregroundColor)
            .frame(width: 25, height: 25)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .foregroundStyle(type.backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(type.strokeColor, lineWidth: 0.3)
            )
    }
    
    var type: AdaptiveDataType {
        dataPoint.type
    }
}

let MockDataPoints: [AdaptiveDataPoint] = [
    .init(type: .healthKit, value: 96.0),
    .init(type: .healthKit, value: 101.0),
    .init(type: .userEntered, value: 96.0),
    .init(type: .averaged, value: 101.0),

    .init(type: .healthKit, value: 3460),
    .init(type: .healthKit, value: 2404),
    .init(type: .userEntered, value: 2781),
    .init(type: .averaged, value: 1853),
]

#Preview {
    Text("Health Details")
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
//                NavigationLink {
                    AdaptiveDataList()
//                } label: {
//                    Text("Show Data")
//                }
            }
        }
        
//        HealthSummary(model: MockHealthModel)
//        List {
//            ForEach(MockDataPoints, id: \.self) { dataPoint in
//                NavigationLink {
//                    AdaptiveDataForm(dataPoint, .dietaryEnergy, Date.now)
//                } label: {
//                    AdaptiveDataCell(dataPoint, Date.now)
//                }
//            }
//        }
}
