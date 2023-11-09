import SwiftUI
import PrepShared

struct HealthSexSection: View {
    
    @Bindable var model: HealthModel
    
    var body: some View {
        Section(header: header, footer: footer) {
            HealthSourcePicker(sourceBinding: $model.sexSource)
            valueRow
            healthKitErrorCell
        }
    }
    
    var header: some View {
        HealthHeader(type: .sex)
            .environment(model)
    }
    
//    var footer: some View {
//        HealthFooter(
//            source: model.heightSource,
//            type: .height,
//            hasQuantity: model.health.heightQuantity != nil
//        )
//    }
    var footer: some View {
        
        HealthFooter(
            source: model.sexSource,
            type: .sex,
            hasQuantity: model.sexValue == .male || model.sexValue == .female
        )

//        var string: String? {
//            switch model.sexSource {
//            case .healthKit:
//                switch model.health.sex?.value {
//                case .none:
//                    healthFooterString(for: .sex, hasQuantity: false)
//                case .female, .male:
//                    healthFooterString(for: .sex, hasQuantity: true)
//                case .other:
//                    "Your sex is specified as 'Other' in the Health app, but either Male or Female is required for biological sex based equations."
//                }
//            case .userEntered:
//                nil
//            }
//        }
//        
//        return Group {
//            if let string {
//                Text(string)
//            }
//        }
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

extension HealthForm {
    var sexSection: some View {
        HealthSexSection(model: model)
//        var pickerContent: some View {
//            HStack {
//                Spacer()
//                MenuPicker<Sex>($model.sexValue)
//            }
//        }
//        
//        var healthContent: some View {
//            var foregroundColor: Color {
//                if model.sexValue != nil, model.sexValue != .notSpecified {
//                    Color(.secondaryLabel)
//                } else {
//                    Color(.tertiaryLabel)
//                }
//            }
//            
//            var string: String {
//                model.sexValue?.name ?? "Unavilable"
//            }
//            
//            return HStack {
//                Spacer()
//                Text(string)
//                    .foregroundStyle(foregroundColor)
//            }
//        }
//        
//        var footer: some View {
//            
//            var string: String? {
//                switch model.sexSource {
//                case .healthKit:
//                    switch model.health.sex?.value {
//                    case .none:
//                        healthFooterString(for: .sex, hasQuantity: false)
//                    case .female, .male:
//                        healthFooterString(for: .sex, hasQuantity: true)
//                    case .notSpecified:
//                        "Your sex is specified as 'Other' in the Health app, but either Male or Female is required for biological sex based equations."
//                    }
//                case .userEntered:
//                    nil
//                }
//            }
//            
//            return Group {
//                if let string {
//                    Text(string)
//                }
//            }
//        }
//        
//        return Section(
//            header: Text("Biological Sex"),
//            footer: footer
//        ) {
//            HealthSourcePicker(sourceBinding: $model.sexSource)
//            switch model.sexSource {
//            case .healthKit:       healthContent
//            case .userEntered:  pickerContent
//            }
//        }
    }
}
