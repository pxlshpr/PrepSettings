//import SwiftUI
//import PrepShared
//
//struct AdaptiveDataCell: View {
//    
//    let sample: MaintenanceSample
//    let date: Date
//    
//    init(_ sample: MaintenanceSample, _ date: Date) {
//        self.sample = sample
//        self.date = date
//    }
//    
//    var body: some View {
//        HStack {
//            image
//            Text("\(sample.value?.cleanAmount ?? "Not Set")")
//            averageLabel
//            Spacer()
//            Text(date.adaptiveMaintenanceDateString)
//                .foregroundStyle(.secondary)
//        }
//    }
//    
//    @ViewBuilder
//    var averageLabel: some View {
//        if type == .averaged {
//            TagView(string: "Average")
//        }
//    }
//    
//    var image: some View {
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
//    }
//    
//    var type: MaintenanceSampleType {
//        sample.type
//    }
//}
