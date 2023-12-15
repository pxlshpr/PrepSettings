import SwiftUI

struct UnitsView: View {
    
    @Environment(\.dismiss) var dismiss
    @Bindable var settingsStore: SettingsStore
    
    var body: some View {
        Form {
            PickerSection($settingsStore.bodyMassUnit, "Body Mass Unit")
        }
        .navigationTitle("Units")
        .toolbar { toolbarContent }
    }
    
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Done") {
                dismiss()
            }
            .fontWeight(.semibold)
        }
    }
}
