import SwiftUI

struct HealthHeaderText: View {
    let string: String
    let isLarge: Bool
    init(_ string: String, isLarge: Bool = false) {
        self.string = string
        self.isLarge = isLarge
    }
    
    var body: some View {
        Text(string)
            .font(.system(isLarge ? .title2 : .title3, design: .rounded, weight: .bold))
            .textCase(.none)
            .foregroundStyle(Color(.label))
    }
}
