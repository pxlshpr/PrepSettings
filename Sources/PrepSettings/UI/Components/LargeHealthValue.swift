import SwiftUI

let LargeNumberFont: Font = .system(.largeTitle, design: .rounded, weight: .bold)
let LargeUnitFont: Font = .system(.body, design: .rounded, weight: .semibold)

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
//                .font(.system(.largeTitle, design: .monospaced, weight: .bold))
                .font(LargeNumberFont)
            Text(unitString)
//                .font(.system(.body, design: .default, weight: .semibold))
                .font(LargeUnitFont)
                .foregroundStyle(.secondary)
        }
    }
}
