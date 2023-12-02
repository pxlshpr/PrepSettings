import SwiftUI
import PrepShared

struct HealthAgeSection: View {
    
    @Bindable var model: HealthModel
    var focusedType: FocusState<HealthType?>.Binding

    init(
        _ model: HealthModel,
        _ focusedType: FocusState<HealthType?>.Binding
    ) {
        self.model = model
        self.focusedType = focusedType
    }
    
    var body: some View {
        Section(header: header, footer: footer) {
            HealthTopRow(type: .age, model: model)
            dateOfBirthPickerField
            valueRow
            healthKitErrorCell
        }
    }
    
    var header: some View {
        HealthBodyProfileTitle(model)
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
        if model.shouldShowHealthKitError(for: .age) {
            HealthKitErrorCell(type: .age)
        }
    }
    
    var numberField: some View {
        NumberField(
            placeholder: "Required",
            binding: $model.ageValue
        )
        .focused(focusedType, equals: .age)
    }
    
    var valueRow: some View {
        HStack {
            Spacer()
            if model.isSettingTypeFromHealthKit(.age) {
                ProgressView()
            } else {
                switch model.ageSource {
                case .healthKit, .userEnteredDateOfBirth:
                    computedContent
                case .userEnteredAge:
                    numberField
                }
                if model.health.age?.value != nil {
                    Text("years")
                        .foregroundStyle(Color(.tertiaryLabel))
                }
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
                    .font(NumberFont)
                    .foregroundStyle(.secondary)
            } else {
                Text(placeholder)
                    .foregroundStyle(.tertiary)
            }
        }
    }
    
    var dateOfBirthPickerField: some View {
        
        let binding = Binding<Date>(
            get: { model.health.ageUserEnteredDateOfBirth ?? DefaultDateOfBirth },
            set: { model.health.ageUserEnteredDateOfBirth = $0 }
        )
        
        return Group {
            if model.ageSource == .userEnteredDateOfBirth {
                HStack {
                    Text("Date of birth")
                    Spacer()
                    DatePicker(
                        "",
                        selection: binding,
                        displayedComponents: [.date]
                    )
                }
            }
        }
    }
}
