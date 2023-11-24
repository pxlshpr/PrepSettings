import SwiftUI

struct TagView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let string: String
    let foregroundColor: Color
    let backgroundColor: Color?
    let fontWeight: Font.Weight
    
    init(
        string: String,
        foregroundColor: Color = Color(.secondaryLabel),
        backgroundColor: Color? = nil,
        fontWeight: Font.Weight = .regular
    ) {
        self.string = string
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.fontWeight = fontWeight
    }
    
    var body: some View {
        Text(string)
            .foregroundStyle(foregroundColor)
            .font(.footnote)
            .fontWeight(fontWeight)
            .padding(.vertical, 3)
            .padding(.horizontal, 5)
            .background(RoundedRectangle(cornerRadius: 6)
                .fill(backgroundColor ?? Color(colorScheme == .dark ? .systemGray4 : .systemGray5)))
    }
}
