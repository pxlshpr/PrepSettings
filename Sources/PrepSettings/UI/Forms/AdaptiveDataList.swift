import SwiftUI
import PrepShared

struct AdaptiveDataList: View {
    
    @State var showingWeight = true
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
            if showingWeight {
                Section("Kilograms") {
                    ForEach([0, 6], id: \.self) {
                        cell(daysAgo: $0)
                    }
                }
            } else {
                Section("Kilocalories") {
                    ForEach(0...6, id: \.self) {
                        cell(daysAgo: $0)
                    }
                }
            }
            if showingWeight {
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
    
    func cell(daysAgo: Int) -> some View {
        NavigationLink {
            
        } label: {
            EmptyView()
//            AdaptiveDataCell(date: Date.now.moveDayBy(-daysAgo))
        }
    }
    
    var toolbarContent: some ToolbarContent {
        Group {
            ToolbarItem(placement: .principal) {
                Picker("", selection: $showingWeight) {
                    Text("Weight").tag(true)
                    Text("Dietary Energy").tag(false)
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

struct AdaptiveDataCell: View {
    
    let dataPoint: AdaptiveDataPoint
    
    var body: some View {
        HStack {
            Image(systemName: dataPoint.type.systemImage)
                .foregroundStyle(dataPoint.type.foregroundColor)
                .frame(width: 25, height: 25)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .foregroundStyle(dataPoint.type.backgroundColor)
                )
            Text("\(dataPoint.value.cleanAmount)")
            Spacer()
            Text(dataPoint.date.logDateString)
                .foregroundStyle(.secondary)
        }
    }
}

enum AdaptiveDataComponent: Int, Hashable, Codable {
    case weight = 1
    case dietaryEnergy
    
    var name: String {
        switch self {
        case .weight:           "Weight"
        case .dietaryEnergy:    "Dietary Energy"
        }
    }
}
enum AdaptiveDataType: Int, Hashable, Codable {
    case healthKit = 1
    case userEntered
    case averaged
    
    var systemImage: String {
        switch self {
        case .averaged:     "chart.line.flattrend.xyaxis" /// "equal"
        case .healthKit:    "heart.fill"
        case .userEntered:  "pencil"
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
}

struct AdaptiveDataPoint: Hashable, Codable {
    let component: AdaptiveDataComponent
    let type: AdaptiveDataType
    let value: Double
    let date: Date
}

let MockDataPoints: [AdaptiveDataPoint] = [
    .init(component: .weight, type: .healthKit, value: 96.0, date: Date.now),
    .init(component: .weight, type: .healthKit, value: 101.0, date: Date.now.moveDayBy(-7)),
    .init(component: .weight, type: .userEntered, value: 96.0, date: Date.now),
    .init(component: .weight, type: .averaged, value: 101.0, date: Date.now.moveDayBy(-7)),

    .init(component: .dietaryEnergy, type: .healthKit, value: 3460, date: Date.now),
    .init(component: .dietaryEnergy, type: .healthKit, value: 2404, date: Date.now.moveDayBy(-7)),
    .init(component: .dietaryEnergy, type: .userEntered, value: 2781, date: Date.now),
    .init(component: .dietaryEnergy, type: .averaged, value: 1853, date: Date.now.moveDayBy(-7)),
]

#Preview {
    NavigationStack {
        List {
            ForEach(MockDataPoints, id: \.self) { dataPoint in
                NavigationLink {
                    
                } label: {
                    AdaptiveDataCell(dataPoint: dataPoint)
                }
            }
        }
    }
}
