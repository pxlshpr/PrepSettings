import Foundation
import PrepShared

public extension Provider {
    
    var healthDetails: HealthDetails {
        get {
            today.healthDetails
        }
        set {
            today.healthDetails = newValue
        }
    }
    
    var biologicalSex: BiologicalSex {
        healthDetails.biologicalSex
    }
    
    var ageInYears: Int? {
        healthDetails.ageInYears
    }
}

extension Provider {
    var unsavedHealthDetails: HealthDetails {
        get { previousToday.healthDetails }
        set { previousToday.healthDetails = newValue }
    }
}
