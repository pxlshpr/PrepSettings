import SwiftUI
import PrepShared

struct AdaptiveDataList: View {
    
    @State var component: AdaptiveDataComponent = .weight
    @State var useMovingAverageForWeight = true

    var body: some View {
        NavigationStack {
            list
                .navigationTitle("Calculation Data")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbarContent }
        }
    }
    
    var list: some View {
        List {
            switch component {
            case .weight:
                Section("Kilograms") {
                    ForEach([0, 6], id: \.self) {
                        cell(daysAgo: $0)
                    }
                }
            case .dietaryEnergy:
                Section("Kilocalories") {
                    ForEach(0...6, id: \.self) {
                        cell(daysAgo: $0)
                    }
                }
            }
            if component == .weight {
                Section(footer: movingAverageFooter) {
                    HStack {
                        Toggle("Use moving average", isOn: $useMovingAverageForWeight)
                    }
                }
            }
        }
    }
    
    var movingAverageFooter: some View {
        Text("Use a 7-day moving average of your weight data when available. This makes the calculation more accurate by accounting for daily changes in your weight due to factors like fluid loss.")
    }
    
    //TODO: Next
    /// [ ] Store data points in health (2 for weight, and 7 for dietary energy)
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
            AdaptiveDataForm(dataPoint, component, Date.now)
        } label: {
            AdaptiveDataCell(dataPoint, Date.now)
        }
    }
    
    var toolbarContent: some ToolbarContent {
        Group {
            ToolbarItem(placement: .principal) {
                Picker("", selection: $component) {
                    Text("Weight").tag(AdaptiveDataComponent.weight)
                    Text("Dietary Energy").tag(AdaptiveDataComponent.dietaryEnergy)
                }
                .pickerStyle(.segmented)
            }
            ToolbarItem(placement: .bottomBar) {
                Button("Fill from Health App") {
                    
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
    NavigationStack {
        List {
            ForEach(MockDataPoints, id: \.self) { dataPoint in
                NavigationLink {
                    AdaptiveDataForm(dataPoint, .dietaryEnergy, Date.now)
                } label: {
                    AdaptiveDataCell(dataPoint, Date.now)
                }
            }
        }
    }
}
