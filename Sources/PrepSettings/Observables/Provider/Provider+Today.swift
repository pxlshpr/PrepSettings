import Foundation
import PrepShared

extension Provider {
    
    var healthDetails: HealthDetails {
        get {
            today.healthDetails
        }
        set {
            today.healthDetails = newValue
        }
    }
    
    var unsavedHealthDetails: HealthDetails {
        get { previousToday.healthDetails }
        set { previousToday.healthDetails = newValue }
    }
    
    var biologicalSex: BiologicalSex {
        healthDetails.biologicalSex
    }
    
    var ageInYears: Int? {
        healthDetails.ageInYears
    }
}
