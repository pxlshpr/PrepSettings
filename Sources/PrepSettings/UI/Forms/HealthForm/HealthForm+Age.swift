import SwiftUI
import PrepShared

struct HealthAgeSection: View {
    
    @Bindable var model: HealthModel

    var body: some View {
        Section(header: header, footer: footer) {
            HealthSourcePicker(sourceBinding: $model.ageSource)
            dateOfBirthPickerField
            valueRow
            healthKitErrorCell
        }
    }
    
    var header: some View {
        HealthHeader(type: .age)
            .environment(model)
    }
    
    var footer: some View {
        HealthFooter(
            source: model.ageSource,
            type: .age,
            hasQuantity: model.health.age?.value != nil
        )
    }
    
    @ViewBuilder
    var healthKitErrorCell: some View {
        if model.health.ageSource == .healthKit, model.health.age?.value == nil {
            HealthKitErrorCell(type: .age)
        }
    }
    
    var valueRow: some View {
        HStack {
            Spacer()
            switch model.ageSource {
            case .healthKit, .userEnteredDateOfBirth:
                computedContent
            case .userEnteredAge:
                NumberTextField(placeholder: "Required", binding: $model.ageValue)
            }
            if model.health.age?.value != nil {
                Text("years")
                    .foregroundStyle(Color(.tertiaryLabel))
            }
        }
    }
    
    var computedContent: some View {
        
        var placeholder: String {
            switch model.ageSource {
            case .healthKit:
                "Unavailable"
            case .userEnteredDateOfBirth:
                "Choose your date of birth"
            case .userEnteredAge:
                "Not set"
            }
        }
        
        return Group {
            if let age = model.health.age?.value {
                Text("\(age)")
                    .font(HealthFont)
                    .foregroundStyle(.secondary)
            } else {
                Text(placeholder)
                    .foregroundStyle(.tertiary)
            }
        }
    }
    
    var dateOfBirthBinding: Binding<Date> {
        Binding<Date>(
            get: { model.health.ageDateOfBirth ?? DefaultDateOfBirth },
            set: { model.health.ageDateOfBirth = $0 }
        )
    }
    
    @ViewBuilder
    var dateOfBirthPickerField: some View {
        if model.ageSource == .userEnteredDateOfBirth {
            HStack {
                Text("Date of birth")
                Spacer()
                DatePicker(
                    "",
                    selection: dateOfBirthBinding,
                    displayedComponents: [.date]
                )
            }
        }
    }
    
}

extension HealthForm {
    var ageSection: some View {
        HealthAgeSection(model: model)
//        var computedContent: some View {
//            
//            var placeholder: String {
//                switch model.ageSource {
//                case .healthKit:
//                    "Unavailable"
//                case .userEnteredDateOfBirth:
//                    "Choose your date of birth"
//                case .userEnteredAge:
//                    "Not set"
//                }
//            }
//            
//            return Group {
//                if let age = model.health.age?.value {
//                    Text("\(age)")
//                        .font(HealthFont)
//                        .foregroundStyle(.secondary)
//                } else {
//                    Text(placeholder)
//                        .foregroundStyle(.tertiary)
//                }
//            }
//        }
//        
//        var dateOfBirthBinding: Binding<Date> {
//            Binding<Date>(
//                get: {
//                    model.health.ageDateOfBirth 
//                    ?? Date.now.moveYearBy(-20)
//                },
//                set: {
//                    model.health.ageDateOfBirth = $0
//                }
//            )
//        }
//        
//        @ViewBuilder
//        var dateOfBirthPickerField: some View {
//            if model.ageSource == .userEnteredDateOfBirth {
//                HStack {
//                    Text("Date of birth")
//                    Spacer()
//                    DatePicker(
//                        "",
//                        selection: dateOfBirthBinding,
//                        displayedComponents: [.date]
//                    )
//                }
//            }
//        }
//        
//        return Section(
//            header: Text("Age"),
//            footer: HealthFooter(
//                source: model.ageSource,
//                type: .age,
//                hasQuantity: model.health.age?.value != nil
//            )
//        ) {
//            HealthSourcePicker(sourceBinding: $model.ageSource)
//            dateOfBirthPickerField
//            HStack {
//                Spacer()
//                switch model.ageSource {
//                case .healthKit, .userEnteredDateOfBirth:
//                    computedContent
//                case .userEnteredAge:
//                    NumberTextField(placeholder: "Required", binding: $model.ageValue)
//                }
//                if model.health.age?.value != nil {
//                    Text("years")
//                        .foregroundStyle(Color(.tertiaryLabel))
//                }
//            }
//        }
    }
}
