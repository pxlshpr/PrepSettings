import SwiftUI

struct LargeHealthValue: View {
    
    let value: Double
    let unitString: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: UnitSpacing) {
            Spacer()
            Text(value.formattedEnergy)
                .animation(.default, value: value)
                .contentTransition(.numericText(value: value))
                .font(.system(.largeTitle, design: .monospaced, weight: .bold))
                .foregroundStyle(.primary)
            Text(unitString)
                .foregroundStyle(.primary)
                .font(.system(.body, design: .default, weight: .semibold))
        }
    }
}
