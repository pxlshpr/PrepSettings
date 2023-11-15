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

    var body: some View {
        list
            .navigationTitle("Adaptive Calculation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
    }
    
    var list: some View {
        List {
            content
        }
    }
    
    @ViewBuilder
    var content: some View {
//        summaryContent
//        componentPickerSection
//            .listRowBackground(EmptyView())
//            .listSectionSpacing(0)
        switch section {
        case .weight:           weightContent
        case .dietaryEnergy:    dietaryEnergyContent
        case .summary:          summaryContent
        }
    }
    
    @ViewBuilder
    var weightContent: some View {
        Section("Kilograms") {
            ForEach([0, 6], id: \.self) {
                cell(daysAgo: $0)
            }
        }
        Section(footer: movingAverageFooter) {
            HStack {
                Toggle("Use Moving Average", isOn: $useMovingAverageForWeight)
            }
        }
        fillAllFromHealthAppSection
    }
    
    @ViewBuilder
    var dietaryEnergyContent: some View {
        Section("Kilocalories") {
            ForEach(0...6, id: \.self) {
                cell(daysAgo: $0)
            }
        }
        fillAllFromHealthAppSection
    }
    
    @ViewBuilder
    var summaryContent: some View {
        Section {
            HStack {
                Text("Number of days")
                Spacer()
                Text("7")
                    .foregroundStyle(.secondary)
                Image(systemName: "chevron.up.chevron.down")
                    .imageScale(.small)
                    .foregroundStyle(.secondary)
            }
        }
        Section(footer: Text("Change in your weight since 7 days ago, converted to energy.")) {
            HStack {
                Text("Weight Change")
                Spacer()
                Text("- 0.69 kg")
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text("Conversion")
                Spacer()
                Text("1 lb = 3500 kcal")
                    .foregroundStyle(.secondary)
                Image(systemName: "chevron.right")
                    .imageScale(.small)
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text("Equivalent Energy")
                Spacer()
                Text("- 5,291 kcal")
                    .foregroundStyle(.secondary)
            }
        }
        Section(footer: Text("Total dietary energy that was consumed over the 7 days leading up to this date.")) {
            HStack {
                Text("Total Dietary Energy")
                Spacer()
                Text("22,146 kcal")
                    .foregroundStyle(.secondary)
            }
        }
        Section(footer: Text("Total energy consumption that would have resulted in no change in weight.")) {
            HStack {
                Text("Total Maintenance")
                Spacer()
                Text("27,437 kcal")
                    .foregroundStyle(.secondary)
            }
        }
        Section(footer: Text("Daily energy consumption that would have resulted in no change in weight, ie. your maintenance.")) {
            HStack {
                Text("Daily Maintenance")
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
        Text("Use a 7-day moving average of your weight data when available. This makes the calculation more accurate by accounting for daily changes in your weight due to factors like fluid loss.")
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
    func cell(daysAgo: Int) -> some View {
        var dataPoint: AdaptiveDataPoint {
            .init(.userEntered, 0)
        }
        return NavigationLink {
            AdaptiveDataForm(dataPoint, section == .weight ? .weight : .dietaryEnergy, Date.now)
        } label: {
            AdaptiveDataCell(dataPoint, Date.now)
        }
    }
    
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            Picker("", selection: $section) {
                ForEach(AdaptiveDataSection.allCases, id: \.self) {
                    Text($0.name).tag($0)
                }
            }
            .pickerStyle(.segmented)
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
    NavigationStack {
        AdaptiveDataList()
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
}
