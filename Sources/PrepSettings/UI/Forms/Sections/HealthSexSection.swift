import SwiftUI
import PrepShared

struct HealthSexSection: View {
    
    @Bindable var model: HealthModel
    
    init(_ model: HealthModel) {
        self.model = model
    }
    
    var body: some View {
        Section(footer: footer) {
//            HealthSourcePicker(sourceBinding: $model.sexSource)
            HealthTopRow(type: .sex, model: model)
            valueRow
            healthKitErrorCell
        }
    }
    
    var header: some View {
        HealthHeader(type: .sex)
            .environment(model)
    }
    
    var footer: some View {
        HealthFooter(
            source: model.sexSource,
            type: .sex,
            hasQuantity: model.sexValue == .male || model.sexValue == .female
        )
    }
    
    @ViewBuilder
    var healthKitErrorCell: some View {
        if model.health.sexSource == .healthKit {
            switch model.health.sex?.value {
            case .none:
                HealthKitErrorCell(type: .sex)
            case .some(let value):
                switch value {
                case .other:
                    Text("⚠️ Your sex is specified as 'Other' in the Health app, but only Male or Female can be used in equations and when picking daily values.")
                        .foregroundStyle(.secondary)
                default:
                    EmptyView()
                }
            }
        }
    }
    
    @ViewBuilder
    var valueRow: some View {
        if let sex = model.health.sex {
            switch sex.source {
            case .healthKit:    healthContent
            case .userEntered:  pickerContent
            }
        }
    }
    
    var pickerContent: some View {
        HStack {
            Spacer()
            MenuPicker([.female, .male], $model.sexValue)
        }
    }
    
    var healthContent: some View {
        var foregroundColor: Color {
            if model.sexValue != nil, model.sexValue != .other {
                Color(.secondaryLabel)
            } else {
                Color(.tertiaryLabel)
            }
        }
        
        var string: String {
            model.sexValue?.name ?? "Unavilable"
        }
        
        return HStack {
            Spacer()
            Text(string)
                .foregroundStyle(foregroundColor)
        }
    }
}
