import SwiftUI
import PrepShared

public struct HealthDetailsForm: View {
    
    @Bindable var provider: Provider
    
    @Binding var isPresented: Bool
    @State var dismissDisabled: Bool = false
    
    public init(
        provider: Provider,
        isPresented: Binding<Bool>
    ) {
        self.provider = provider
        _isPresented = isPresented
    }
    
    public var body: some View {
        NavigationView {
            form
                .navigationTitle("Health Details")
                .navigationBarTitleDisplayMode(.large)
                .toolbar { toolbarContent }
        }
//        .interactiveDismissDisabled(dismissDisabled)
        .interactiveDismissDisabled(true)
    }
    
    var form: some View {
        Form {
            dateSection
            Section {
                link(for: .maintenance)
            }
            Section {
                link(for: .weight)
                link(for: .height)
            }
            Section {
                link(for: .leanBodyMass)
                link(for: .fatPercentage)
            }
            Section {
                link(for: .age)
                link(for: .biologicalSex)
//                if shouldShowSmokingStatus {
                    link(for: .smokingStatus)
//                }
                if shouldShowPregnancyStatus {
                    link(for: .preganancyStatus)
                }
            }
        }
    }
    
    var shouldShowPregnancyStatus: Bool {
        provider.healthDetails.biologicalSex == .female
//        && provider.healthDetails.smokingStatus != .smoker
    }
    
    var shouldShowSmokingStatus: Bool {
        !provider.healthDetails.pregnancyStatus.isPregnantOrLactating
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
    
    func link(for healthDetail: HealthDetail) -> some View {
        var details: HealthDetails { provider.healthDetails }
        
        var primaryText: some View {
            Text(details.valueString(for: healthDetail, provider))
                .foregroundStyle(details.hasSet(healthDetail) ? .primary : .secondary)
        }
        
        return NavigationLink {
            sheet(for: healthDetail)
        } label: {
            HStack {
                Text(healthDetail.name)
                Spacer()
                HStack(spacing: 4) {
//                    secondaryText
                    primaryText
                }
            }
        }
    }
    
    @ViewBuilder
    var dateSection: some View {
        if !provider.healthDetails.date.isToday {
            NoticeSection.legacy(provider.healthDetails.date)
//            Section {
//                HStack {
//                    Text("Date")
//                    Spacer()
//                    Text(provider.healthDetails.date.shortDateString)
//                }
//            }
        }
    }
    
    @ViewBuilder
    func sheet(for route: HealthDetail) -> some View {
        switch route {
        case .maintenance:
            MaintenanceForm(
                provider: provider,
                isPresented: $isPresented
            )
        case .leanBodyMass:
            LeanBodyMassForm(
                provider: provider,
                isPresented: $isPresented
            )
        case .fatPercentage:
            FatPercentageForm(
                provider: provider,
                isPresented: $isPresented
            )
        case .weight:
            WeightForm(
                provider: provider,
                isPresented: $isPresented
            )
        case .height:
            HeightForm(
                provider: provider,
                isPresented: $isPresented
            )
        case .age:
            AgeForm(
                provider: provider,
                isPresented: $isPresented
            )
        case .biologicalSex:
            BiologicalSexForm(
                provider: provider,
                isPresented: $isPresented
            )
        case .preganancyStatus:
            PregnancyStatusForm(
                provider: provider,
                isPresented: $isPresented
            )
        case .smokingStatus:
            SmokingStatusForm(
                provider: provider,
                isPresented: $isPresented
            )
        }
    }
}

//#Preview("Current") {
//    MockCurrentHealthDetailsForm()
//}
//
//#Preview("Past") {
//    MockPastHealthDetailsForm()
//}

#Preview("SettingsDemoView") {
    SettingsDemoView()
}
