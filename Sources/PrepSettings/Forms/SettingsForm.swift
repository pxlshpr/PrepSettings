import SwiftUI
import PrepShared

public struct SettingsForm: View {
    
    @Bindable var provider: Provider
    @Binding var isPresented: Bool
    
    public init(
        _ provider: Provider = Provider.shared,
        isPresented: Binding<Bool> = .constant(false)
    ) {
        self.provider = provider
        _isPresented = isPresented
    }
    
    public var body: some View {
        NavigationView {
            Form {
                energyUnitPicker
                bodyMassUnitPicker
                heightUnitPicker
            }
            .navigationTitle("Settings")
        }
    }

    var energyUnitPicker: some View {
        let binding = Binding<EnergyUnit>(
            get: { provider.settings.energyUnit },
            set: { newValue in
                provider.saveEnergyUnit(newValue)
            }
        )
        return PickerSection(binding, "Energy Unit")
    }
    
    var heightUnitPicker: some View {
        let binding = Binding<HeightUnit>(
            get: { provider.settings.heightUnit },
            set: { newValue in
                provider.saveHeightUnit(newValue)
            }
        )
        return PickerSection(binding, "Height Unit")
    }
    
    var bodyMassUnitPicker: some View {
        let binding = Binding<BodyMassUnit>(
            get: { provider.settings.bodyMassUnit },
            set: { newValue in
                provider.saveBodyMassUnit(newValue)
            }
        )
        return PickerSection(binding, "Body Mass Unit")
    }
}

#Preview {
    SettingsForm()
}
