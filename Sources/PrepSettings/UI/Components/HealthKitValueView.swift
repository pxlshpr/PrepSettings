import SwiftUI
import PrepShared

struct HealthKitValueView<S: GenericSource>: View {
    
    var binding: Binding<Double?>
    let source: S
    let showPrecision: Bool
    
    init(_ binding: Binding<Double?>, _ source: S, showPrecision: Bool = true) {
        self.binding = binding
        self.source = source
        self.showPrecision = showPrecision
    }

    var body: some View {
        Group {
            if let double = binding.wrappedValue {
                numberView(double)
            } else {
                placeholderView
            }
        }
    }
    
    func numberView(_ double: Double) -> some View {
        
        var rounded: Double {
            showPrecision ? double : double.rounded(.down)
        }
        
        return Text("\(rounded.clean)")
            .font(.system(.body, design: .monospaced, weight: .bold))
            .animation(.default, value: binding.wrappedValue)
            .contentTransition(.numericText(value: double))
            .foregroundStyle(.secondary)
    }
    
    var placeholderView: some View {
        Text(source.placeholder)
            .foregroundStyle(.tertiary)
    }
}
