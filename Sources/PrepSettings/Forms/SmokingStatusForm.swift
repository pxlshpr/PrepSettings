import SwiftUI
import SwiftSugar
import PrepShared

struct SmokingStatusForm: View {
    
    @Binding var isPresented: Bool
    let date: Date
    @State var smokingStatus: SmokingStatus = .notSet
    let saveHandler: (SmokingStatus) -> ()
    
    init(
        date: Date,
        smokingStatus: SmokingStatus,
        isPresented: Binding<Bool> = .constant(true),
        save: @escaping (SmokingStatus) -> ()
    ) {
        self.date = date
        self.saveHandler = save
        _isPresented = isPresented
        _smokingStatus = State(initialValue: smokingStatus)
    }
    
    init(
        provider: Provider,
        isPresented: Binding<Bool> = .constant(true)
    ) {
        self.init(
            date: provider.healthDetails.date,
            smokingStatus: provider.healthDetails.smokingStatus,
            isPresented: isPresented,
            save: provider.saveSmokingStatus
        )
    }

    var body: some View {
        Form {
            dateSection
            picker
            explanation
        }
        .navigationTitle("Smoking Status")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { toolbarContent }
        .safeAreaInset(edge: .bottom) { bottomValue }
    }
    
    var dateSection: some View {
        Section {
            HStack {
                Text("Date")
                Spacer()
                Text(date.shortDateString)
            }
        }
    }
    
    var bottomValue: some View {
        HStack(alignment: .firstTextBaseline, spacing: 5) {
            Spacer()
            ZStack {
                
                /// dummy text placed to ensure height stays consistent
                Text("0")
                    .font(LargeNumberFont)
                    .opacity(0)

                Text(smokingStatus.name)
                    .font(NotSetFont)
                    .foregroundStyle(smokingStatus == .notSet ? .secondary : .primary)
            }
        }
        .padding(.horizontal, BottomValueHorizontalPadding)
        .padding(.vertical, BottomValueVerticalPadding)
        .background(.bar)
    }
    
    var picker: some View {
        let binding = Binding<SmokingStatus>(
            get: { smokingStatus },
            set: { newValue in
                self.smokingStatus = newValue
                handleChanges()
            }
        )
        return PickerSection(
            [SmokingStatus.nonSmoker, SmokingStatus.smoker],
            binding
        )
    }
    
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                isPresented = false
            } label: {
                CloseButtonLabel()
            }
        }
    }
    
    func handleChanges() {
        save()
    }
    
    func save() {
        saveHandler(smokingStatus)
    }
    
    var explanation: some View {
        var header: some View {
            Text("Usage")
                .formTitleStyle()
        }

        return Section(header: header) {
            Text("Your smoking status may be used when picking daily values for micronutrients.\n\nFor example, if you are a smoker then the recommended daily allowance of Vitamin C will be slightly higher.")
        }
    }

}

#Preview("SettingsDemoView") {
    SettingsDemoView()
}
