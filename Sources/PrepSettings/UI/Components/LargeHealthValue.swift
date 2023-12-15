import SwiftUI

let LargeNumberFont: Font = .system(.largeTitle, design: .rounded, weight: .bold)
let LargeUnitFont: Font = .system(.body, design: .rounded, weight: .semibold)

struct LargeHealthValue: View {
    
    let value: Double
    let valueString: String
    let valueColor: Color
    let unitString: String
    
    init(
        value: Double,
        valueString: String,
        valueColor: Color = .primary,
        unitString: String
    ) {
        self.value = value
        self.valueString = valueString
        self.valueColor = valueColor
        self.unitString = unitString
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: UnitSpacing) {
            Spacer()
            Text(valueString)
                .animation(.default, value: value)
                .contentTransition(.numericText(value: value))
//                .font(.system(.largeTitle, design: .monospaced, weight: .bold))
                .font(LargeNumberFont)
                .foregroundStyle(valueColor)
            Text(unitString)
//                .font(.system(.body, design: .default, weight: .semibold))
                .font(LargeUnitFont)
                .foregroundStyle(.secondary)
        }
    }
}
