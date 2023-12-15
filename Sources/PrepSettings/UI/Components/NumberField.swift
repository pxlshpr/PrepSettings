import SwiftUI
import PrepShared

//public let NumberFont = Font.system(.body, design: .monospaced, weight: .bold)
public let NumberFont = Font.system(.body)

public struct NumberField: View {
    
    let placeholder: String
    
    let roundUp: Bool
    let doubleBinding: Binding<Double?>?
    let stringBinding: Binding<String?>?

    let intBinding: Binding<Int?>?
    let disabled: Binding<Bool>?
    
    @State var includeTrailingPeriod: Bool = false
    @State var includeTrailingZero: Bool = false
    @State var numberOfTrailingZeros: Int = 0

    let font: Font?
    
    public init(
        placeholder: String = "",
        roundUp: Bool = false,
        binding: Binding<Double?>,
        stringBinding: Binding<String?>,
        font: Font? = nil,
        disabled: Binding<Bool>? = nil
    ) {
        self.placeholder = placeholder
        self.roundUp = roundUp
        self.doubleBinding = binding
        self.stringBinding = stringBinding
        self.intBinding = nil
        self.font = font
        self.disabled = disabled
    }
    
    public init(
        placeholder: String = "",
        binding: Binding<Int?>,
        font: Font? = nil,
        disabled: Binding<Bool>? = nil
    ) {
        self.placeholder = placeholder
        self.roundUp = true
        self.intBinding = binding
        self.doubleBinding = nil
        self.stringBinding = nil
        self.font = font
        self.disabled = disabled
    }
    
    public var body: some View {
        textField
            .textFieldStyle(.plain)
            .font(font ?? NumberFont)
            .foregroundStyle(foregroundColor)
            .multilineTextAlignment(.trailing)
            .keyboardType(roundUp ? .numberPad : .decimalPad)
            .simultaneousGesture(textSelectionTapGesture)
            .disabled(disabled?.wrappedValue ?? false)
    }
    
    var foregroundColor: Color {
        if let disabled {
            disabled.wrappedValue ? .secondary : .primary
        } else {
            .primary
        }
    }

    var textField: some View {
        let textBinding = Binding<String>(
            get: {
                if let string = stringBinding?.wrappedValue {
                    return string
                } else if let doubleBinding {
                    
                    var string: String
                    
                    if let value = doubleBinding.wrappedValue {
                        
                        print("Getting string for: \(value)")
                        if includeTrailingZero {
                            string = "0.0"
                        } else {
                            if roundUp {
                                let formatter = NumberFormatter.input(0)
                                let number = NSNumber(value: value)
                                string = formatter.string(from: number) ?? ""
                            } else {
                                string = "\(NSNumber(value: value).decimalValue)"
//                                if string.hasSuffix(".0") {
//                                    string.removeLast(2)
//                                }
//                                string = "\(NSNumber(value: value).doubleValue)"
                            }
                        }
                        
                    } else {
                        string = ""
                    }
                    string = string + "\(includeTrailingPeriod ? "." : "")"
                    print("Returning \(string)")
                    return string
                } else if let intBinding, let value = intBinding.wrappedValue {
                    return "\(value)"
                } else {
                    return ""
                }
            },
            set: { newValue in
                if let doubleBinding {
                    
                    /// Cleanup by removing any extra periods and non-numbers
                    let newValue = newValue.sanitizedDouble
                    stringBinding?.wrappedValue = newValue
                    
                    print("newValue: \(newValue)")
                    /// If we haven't already set the flag for the trailing period, and the string has period as its last character, set it so that its displayed
                    if !includeTrailingPeriod, newValue.last == "." {
                        print("setting includeTrailingPeriod to true")
                        includeTrailingPeriod = true
                    }
                    /// If we have set the flag for the trailing period and the last character isn't it—unset it
                    else if includeTrailingPeriod, newValue.last != "." {
                        print("setting includeTrailingPeriod to false")
                        includeTrailingPeriod = false
                    }
                    
                    if newValue == ".0" {
                        includeTrailingZero = true
                    } else {
                        includeTrailingZero = false
                    }
                    
                    let double = Double(newValue)
                    print("setting doubleBinding with: \(String(describing: double))")
                    doubleBinding.wrappedValue = double
                } else if let intBinding {
                    intBinding.wrappedValue = Int(newValue)
                }
            }
        )
        
        return TextField("", text: textBinding)
    }
    
//    var keyboardToolbarContent: some ToolbarContent {
//        ToolbarItemGroup(placement: .keyboard) {
//            HStack {
//                Spacer()
//                Button("Done") {
//                    isFocused = false
//                }
//                .fontWeight(.semibold)
//            }
//        }
//    }
}



struct NumberFieldTest: View {
    
    @State var value: Double? = 500
    @State var valueString: String? = "500"

    var body: some View {
        NavigationStack {
            Form {
                HStack {
                    Spacer()
                    NumberField(
                        placeholder: "Placeholder",
                        binding: $value,
                        stringBinding: $valueString
                    )
                }
            }
        }
    }
}

#Preview {
    NumberFieldTest()
}
