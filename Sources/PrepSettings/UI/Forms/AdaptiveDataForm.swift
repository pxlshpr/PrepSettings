import SwiftUI
import PrepShared

struct AdaptiveDataForm: View {
    
    @State var model: Model
    
    @Observable class Model {
        
        let date: Date
        let dataPoint: AdaptiveDataPoint
        var type: AdaptiveDataType
        var component: AdaptiveDataComponent
        var value: Double

        init(_ dataPoint: AdaptiveDataPoint, _ component: AdaptiveDataComponent, _ date: Date) {
            self.dataPoint = dataPoint
            self.type = dataPoint.type
            self.component = component
            self.value = dataPoint.value
            self.date = date
        }
    }
    
    init(_ dataPoint: AdaptiveDataPoint, _ component: AdaptiveDataComponent, _ date: Date) {
        _model = State(initialValue: Model(dataPoint, component, date))
    }
    
    var body: some View {
        Form {
            Section {
                typeRow
                valueRow
            }
        }
        .navigationTitle(model.date.adaptiveMaintenanceDateString)
        .toolbar { toolbarContent }
    }
    
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Save") {
                
            }
            .disabled(true)
        }
    }
    
    @ViewBuilder
    var valueRow: some View {
        HStack {
            Spacer()
            switch model.type {
            case .userEntered:  manualValue
            case .healthKit:    healthValue
            case .averaged:     healthValue
            }
        }
    }
    
    var typeRow: some View {
        HStack {
            Text(model.component.name)
            Spacer()
            MenuPicker($model.type)
        }
    }
    
    var manualValue: some View {
        ManualHealthField(
            unitBinding: .constant(BodyMassUnit.kg),
            valueBinding: $model.value,
            firstComponentBinding: .constant(0),
            secondComponentBinding: .constant(0)
        )
    }
    
    var healthValue: some View {
        CalculatedHealthView(
            quantityBinding: .constant(Quantity(value: 96.0, date: Date.now)),
            secondComponent: 0,
            unitBinding: .constant(BodyMassUnit.kg),
            source: model.type
        )
    }
}


public enum AdaptiveDataComponent: Int, Hashable, Codable {
    case weight = 1
    case dietaryEnergy
}

public extension AdaptiveDataComponent {
    var name: String {
        switch self {
        case .weight:           "Weight"
        case .dietaryEnergy:    "Dietary Energy"
        }
    }
}

public struct AdaptiveDataPoint: Hashable, Codable {
    let type: AdaptiveDataType
    let value: Double

    init(type: AdaptiveDataType, value: Double) {
        self.type = type
        self.value = value
    }

    init(_ type: AdaptiveDataType, _ value: Double) {
        self.type = type
        self.value = value
    }
}

#Preview {
    NavigationStack {
        AdaptiveDataForm(MockDataPoints[1], .dietaryEnergy, Date.now)
    }
}

public struct AdaptiveWeightDataPoints: Hashable, Codable {
    public let current: AdaptiveDataPoint?
    public let previous: AdaptiveDataPoint?
}

public extension AdaptiveWeightDataPoints {
    var delta: Double? {
        guard let current, let previous else { return nil }
        return current.value - previous.value
    }
}

public struct AdaptiveDietaryEnergyDataPoints: Hashable, Codable {
    static let DefaultNumberOfPoints = 7
    
    public let numberOfDays: Int
    public var points: [Int: AdaptiveDataPoint] = [:]
    
    init(numberOfDays: Int = DefaultNumberOfPoints) {
        self.numberOfDays = numberOfDays
    }
}

extension AdaptiveDataPoint: CustomStringConvertible {
    public var description: String {
        "\(value.cleanAmount) (\(type.name))"
    }
}

extension AdaptiveDietaryEnergyDataPoints: CustomStringConvertible {
    public var description: String {
        var string = ""
        for day in 0..<numberOfDays {
            if let point = points[day] {
                string += "[\(day)] → \(point.description)\n"
            } else {
                string += "[\(day)] → nil\n"
            }
        }
        return string
    }
}

public extension AdaptiveDietaryEnergyDataPoints {
    mutating func setPoint(at index: Int, with point: AdaptiveDataPoint) {
        points[index] = point
    }
    
    func point(at index: Int) -> AdaptiveDataPoint? {
        points[index]
    }
    
    func hasPoint(at index: Int) -> Bool {
        points[index] != nil
    }
}

public extension AdaptiveDietaryEnergyDataPoints {
    
    var average: Double? {
        let values = points.values.map { $0.value }
        guard !values.isEmpty else { return nil }
        let sum = values.reduce(0) { $0 + $1 }
        return Double(sum) / Double(values.count)
    }
    
    mutating func fillEmptyValuesWithAverages() {
        guard let average else { return }
        for i in 0..<numberOfDays {
            /// Only fill with average if there is no value for it
            guard points[i] == nil else { continue }
            points[i] = .init(.averaged, average)
        }
    }
}
