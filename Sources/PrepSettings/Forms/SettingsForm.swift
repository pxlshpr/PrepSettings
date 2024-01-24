import SwiftUI
import PrepShared

public struct SettingsForm: View {
    
    @Bindable var settingsProvider: SettingsProvider
    @Binding var isPresented: Bool
    
    public init(
//        _ settingsProvider: SettingsProvider = SettingsProvider(settings: .init()),
        _ settingsProvider: SettingsProvider = SettingsProvider.shared,
        isPresented: Binding<Bool> = .constant(false)
    ) {
        self.settingsProvider = settingsProvider
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
            get: { settingsProvider.settings.energyUnit },
            set: { newValue in
                settingsProvider.saveEnergyUnit(newValue)
            }
        )
        return PickerSection(binding, "Energy Unit")
    }
    
    var heightUnitPicker: some View {
        let binding = Binding<HeightUnit>(
            get: { settingsProvider.settings.heightUnit },
            set: { newValue in
                settingsProvider.saveHeightUnit(newValue)
            }
        )
        return PickerSection(binding, "Height Unit")
    }
    
    var bodyMassUnitPicker: some View {
        let binding = Binding<BodyMassUnit>(
            get: { settingsProvider.settings.bodyMassUnit },
            set: { newValue in
                settingsProvider.saveBodyMassUnit(newValue)
            }
        )
        return PickerSection(binding, "Body Mass Unit")
    }
}

#Preview {
    SettingsForm()
}
