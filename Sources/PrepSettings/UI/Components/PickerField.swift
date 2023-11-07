import SwiftUI
import PrepShared

struct PickerField<P: Pickable>: View {
    
    let label: String
    let binding: Binding<P>
   
    init(_ label: String, _ binding: Binding<P>) {
        self.label = label
        self.binding = binding
    }
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            MenuPicker<P>(binding)
        }
    }
}
