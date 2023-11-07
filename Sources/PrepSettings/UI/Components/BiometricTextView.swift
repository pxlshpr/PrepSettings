import SwiftUI
import PrepShared

struct BiometricTextView<Unit: BiometricUnit>: View {
    
    let unit: Unit
    let value: Double
    let secondComponent: Double

    @ViewBuilder
    var body: some View {
        switch unit.hasTwoComponents {
        case true:
            HStack {
                HStack(spacing: 3) {
                    Text("\(Int(value.whole))")
                        .font(BiometricFont)
                        .contentTransition(.numericText(value: value.whole))
                        .animation(.default, value: value)
                    Text(unit.abbreviation)
                }
                if secondComponent.biometricString != "0" {
                    HStack(spacing: 3) {
                        Text(secondComponent.biometricString)
                            .font(BiometricFont)
                            .contentTransition(.numericText(value: secondComponent))
                            .animation(.default, value: secondComponent)
                        if let string = Unit.secondaryUnit {
                            Text(string)
                        }
                    }
                }
            }
        case false:
            HStack(spacing: 3) {
                Text(value.biometricString)
                    .font(BiometricFont)
                    .contentTransition(.numericText(value: value))
                    .animation(.default, value: value)
                Text(unit.abbreviation)
            }
        }
    }
}
