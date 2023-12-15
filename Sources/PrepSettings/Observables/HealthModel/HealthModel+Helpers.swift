import Foundation
import SwiftSugar

extension HealthModel {
    
    func focusedTypeChanged(old: HealthType?, new: HealthType?) {
//        for type in HealthType.allCases {
//            if old == type, new != type {
//                health.handleFocusLoss(for: type)
//            }
//        }
    }
    
    func remove(_ type: HealthType) {
        health.remove(type)
    }
    
    func add(_ type: HealthType) {
        
        health.add(type)
        
        switch type {
        case .maintenance:
            Task {
//                try await sleepTask(1)
                try await fetchBackendValuesForAdaptiveMaintenance()
            }
        default:
            break
        }
    }
    
    var isEditingPast: Bool {
        !isCurrent && isEditing
    }
    
    var isLocked: Bool {
        !isCurrent && !isEditing
    }
}
