import SwiftUI

/// Provides a binding for inputting a double
@Observable public class DoubleInput {
    
    public var double: Double?
    
    private var stringAsDouble: Double?
    private var string: String
    private var includeTrailingPeriod: Bool = false
    private var includeTrailingZero: Bool = false
    private var numberOfTrailingZeros: Int = 0
    private let automaticallySubmitsValues: Bool
    
    public init(double: Double? = nil, automaticallySubmitsValues: Bool = false) {
        self.double = double
        self.stringAsDouble = double
        self.string = double?.clean ?? ""
        self.automaticallySubmitsValues = automaticallySubmitsValues
    }
    
    public func setDouble(_ double: Double?) {
        self.double = double
        self.stringAsDouble = double
        self.string = double?.clean ?? ""
    }
}

extension DoubleInput {
    
    var binding: Binding<String> {
        Binding<String>(
            get: { self.string },
            set: { newValue in
                self.setNewValue(newValue)
            }
        )
    }
    
    func setNewValue(_ newValue: String) {
        /// Cleanup by removing any extra periods and non-numbers
        let newValue = newValue.sanitizedDouble
        string = newValue
        
        /// If we haven't already set the flag for the trailing period, and the string has period as its last character, set it so that its displayed
        if !includeTrailingPeriod, newValue.last == "." {
            includeTrailingPeriod = true
        }
        /// If we have set the flag for the trailing period and the last character isn't it—unset it
        else if includeTrailingPeriod, newValue.last != "." {
            includeTrailingPeriod = false
        }
        
        if newValue == ".0" {
            includeTrailingZero = true
        } else {
            includeTrailingZero = false
        }
        
        let double = Double(newValue)
        stringAsDouble = double
        
        if automaticallySubmitsValues {
            submitValue()
        }
    }
    
    func submitValue() {
        double = stringAsDouble
    }
    
    func cancel() {
        guard let double else {
            string = ""
            stringAsDouble = nil
            return
        }
        string = double.clean
        stringAsDouble = double
    }
}
