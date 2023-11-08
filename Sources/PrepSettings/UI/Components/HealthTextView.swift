import SwiftUI
import PrepShared

struct HealthTextView<Unit: HealthUnit>: View {
    
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
                        .font(HealthFont)
                        .contentTransition(.numericText(value: value.whole))
                        .animation(.default, value: value)
                    Text(unit.abbreviation)
                }
                if secondComponent.healthString != "0" {
                    HStack(spacing: 3) {
                        Text(secondComponent.healthString)
                            .font(HealthFont)
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
                Text(value.healthString)
                    .font(HealthFont)
                    .contentTransition(.numericText(value: value))
                    .animation(.default, value: value)
                Text(unit.abbreviation)
            }
        }
    }
}
