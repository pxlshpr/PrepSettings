import Foundation

public extension HealthModel {
    var hasAdaptiveMaintenanceEnergyValue: Bool {
        maintenanceEnergyIsAdaptive
        && health.maintenanceEnergy?.adaptiveValue != nil
        && health.maintenanceEnergy?.error == nil
    }
}

extension HealthModel {
    func remove(_ type: HealthType) {
        health.remove(type)
    }
    
    func add(_ type: HealthType) {
        health.add(type)
    }
}
