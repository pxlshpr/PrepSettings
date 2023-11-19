import SwiftUI
import PrepShared

struct SampleCell: View {
    
    let sample: MaintenanceSample
    let date: Date
    let component: AdaptiveDataComponent
    
    init(sample: MaintenanceSample, date: Date, component: AdaptiveDataComponent) {
        self.sample = sample
        self.date = date
        self.component = component
    }
    
    @ViewBuilder
    var value: some View {
        if let value = sample.value {
            Text("\(component == .dietaryEnergy ? value.formattedEnergy : value.rounded(toPlaces: 1).cleanAmount)")
        } else {
            Text("Not set")
                .foregroundStyle(.secondary)
        }
    }
    
    var body: some View { 
        HStack {
            image
            value
//            averageLabel
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
        sample.type
    }
}

