import SwiftUI
import PrepShared

struct DietaryEnergySampleCell: View {
    
    let sample: MaintenanceDietaryEnergySample
    let date: Date
    
    init(sample: MaintenanceDietaryEnergySample, date: Date) {
        self.sample = sample
        self.date = date
    }
    
    @ViewBuilder
    var value: some View {
        if let value = sample.value {
            Text(value.formattedEnergy)
        } else {
            Text("Not set")
                .foregroundStyle(.secondary)
        }
    }
    
    var body: some View { 
        HStack {
            Text(date.adaptiveMaintenanceDateString)
            Spacer()
            type
            value
                .foregroundStyle(.secondary)
//            averageLabel
        }
    }
    
//    @ViewBuilder
//    var averageLabel: some View {
//        if type == .averaged {
//            TagView(string: "Average")
//        }
//    }
//    
    @ViewBuilder
    var type: some View {
        switch sample.type {
        case .healthKit:
            Text("HealthKit")
                .foregroundStyle(.tertiary)
        case .backend:
            EmptyView()
        case .averaged:
            Text("Average")
                .foregroundStyle(.tertiary)
        }
//        Image(systemName: type.systemImage)
//            .foregroundStyle(type.foregroundColor)
//            .frame(width: 25, height: 25)
//            .background(
//                RoundedRectangle(cornerRadius: 4)
//                    .foregroundStyle(type.backgroundColor)
//            )
//            .overlay(
//                RoundedRectangle(cornerRadius: 4)
//                    .stroke(type.strokeColor, lineWidth: 0.3)
//            )
    }
//    
//    var type: MaintenanceSampleType {
//        sample.type
//    }
}


struct WeightSampleCell: View {
    
    let sample: MaintenanceWeightSample
    let date: Date
    
    init(sample: MaintenanceWeightSample, date: Date) {
        self.sample = sample
        self.date = date
    }
    
    @ViewBuilder
    var value: some View {
        if let value = sample.value {
            Text(value.rounded(toPlaces: 1).cleanAmount)
        } else {
            Text("Not set")
                .foregroundStyle(.secondary)
        }
    }
    
    var body: some View {
        HStack {
            value
//            averageLabel
            Spacer()
            Text(date.adaptiveMaintenanceDateString)
                .foregroundStyle(.secondary)
        }
    }
    
//    @ViewBuilder
//    var averageLabel: some View {
//        if type == .averaged {
//            TagView(string: "Average")
//        }
//    }
}

