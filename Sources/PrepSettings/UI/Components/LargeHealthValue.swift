import SwiftUI

struct LargeHealthValue: View {
    
    let value: Double
    let valueString: String
    let unitString: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: UnitSpacing) {
            Spacer()
            Text(valueString)
                .animation(.default, value: value)
                .contentTransition(.numericText(value: value))
                .font(.system(.largeTitle, design: .monospaced, weight: .bold))
            Text(unitString)
                .font(.system(.body, design: .default, weight: .semibold))
        }
    }
}
