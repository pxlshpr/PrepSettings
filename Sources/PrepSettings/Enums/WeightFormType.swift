import Foundation

enum WeightFormType: Equatable {
    case healthDetails
    case adaptiveSample(isPrevious: Bool)
    case specificDate
}

extension WeightFormType {
    var isPreviousSample: Bool? {
        switch self {
        case .adaptiveSample(let isPrevious):   isPrevious
        default:                                nil
        }
    }
    
    var isAdaptiveSample: Bool {
        switch self {
        case .adaptiveSample:   true
        default:                false
        }
    }
}
