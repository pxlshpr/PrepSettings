import SwiftUI
import PrepShared

public struct PickerSection<T: Pickable>: View {
    
    let options: [T]
    let binding: Binding<T>
    let title: String?
    
    public init(
        _ options: [T],
        _ binding: Binding<T>,
        _ title: String? = nil
    ) {
        self.options = options
        self.binding = binding
        self.title = title
    }

    public init(
        _ binding: Binding<T>,
        _ title: String? = nil
    ) {
        self.options = T.allCases as! [T]
        self.binding = binding
        self.title = title
    }

    public init(
        _ binding: Binding<T?>,
        _ title: String? = nil
    ) {
        self.options = T.allCases as! [T]
        self.binding = Binding<T>(
            get: { binding.wrappedValue ?? T.noneOption ?? T.default },
            set: { binding.wrappedValue = $0 }
        )
        self.title = title
    }

    public init(
        _ options: [T],
        _ binding: Binding<T?>,
        _ title: String?
    ) {
        self.options = options
        self.binding = Binding<T>(
            get: { binding.wrappedValue ?? T.noneOption ?? T.default },
            set: { binding.wrappedValue = $0 }
        )
        self.title = title
    }
    
    public var body: some View {
        Section(header: header) {
            ForEach(options, id: \.self) { option in
                button(for: option)
            }
        }
    }
    
    func button(for option: T) -> some View {
        Button {
            binding.wrappedValue = option
        } label: {
            label(for: option)
        }
    }
    
    func label(for option: T) -> some View {
        var checkmark: some View {
            Image(systemName: "checkmark")
                .opacity(binding.wrappedValue == option ? 1 : 0)
        }
        
        var content: some View {
            func withDescription(_ description: String) -> some View {
                VStack(alignment: .leading) {
                    Text(option.menuTitle)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(.label))
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(Color(.secondaryLabel))
                }
            }
            
            var standard: some View {
                Text(option.menuTitle)
                    .foregroundStyle(Color(.label))
            }
            
            return Group {
                if let description = option.description {
                    withDescription(description)
                } else {
                    standard
                }
            }
        }
        
        @ViewBuilder
        var detail: some View {
            if let detail = option.detail {
                Text(detail)
                    .foregroundStyle(Color(.secondaryLabel))
            }
        }
        
        return HStack {
            checkmark
            content
            Spacer()
            detail
        }
    }
    
    @ViewBuilder
    var header: some View {
        if let title {
            Text(title)
        }
    }
}
