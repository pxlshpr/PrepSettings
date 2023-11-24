import SwiftUI
import PrepShared

public struct MaintenanceEstimateForm: View {
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
        .navigationTitle("Maintenance Energy")
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
                Text("Estimated")
                Spacer()
                MaintenanceEstimateText(model)
            }
        }
    }
}
