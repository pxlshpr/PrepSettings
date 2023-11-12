import SwiftUI
import OSLog
import HealthKit
import CoreData

import PrepShared

@Observable public class HealthModel {

    public let isCurrent: Bool
    public var ignoreChanges: Bool = false
    
    internal let logger = Logger(subsystem: "HealthModel", category: "")
    internal var handleChangesTask: Task<Void, Error>? = nil
    
    var fetchCurrentHealthHandler: (() async throws -> Health)? = nil
    var saveHandler: ((Health, Bool) async throws -> ())
    
    public var health: Health {
        didSet {
            guard !ignoreChanges else { return }
            handleChanges(from: oldValue)
        }
    }
    
    var typesBeingSetFromHealthKit: [HealthType] = []

    /// Current Health
    public init(
        fetchCurrentHealthHandler: (@escaping () async throws -> Health),
        saveHandler: (@escaping (Health, Bool) async throws -> ())
    ) {
        self.fetchCurrentHealthHandler = fetchCurrentHealthHandler
        self.saveHandler = saveHandler
        self.health = Health()
        self.isCurrent = true
        loadCurrentHealth(fetchCurrentHealthHandler)
    }
    
    /// Past Health
    public init(
        health: Health,
        saveHandler: (@escaping (Health, Bool) async throws -> ())
    ) {
        self.fetchCurrentHealthHandler = nil
        self.saveHandler = saveHandler
        self.health = health
        self.isCurrent = false
    }

    public func loadCurrentHealth(_ handler: @escaping (() async throws -> Health)) {
        Task {
            let health = try await handler()
            await MainActor.run {
                /// Ignoring changes so that we don't trigger permissions and health fetches implicitly (we should do it explicitly at the right time, and not when loading this)
                ignoreChanges = true
                self.health = health
                ignoreChanges = false
                post(.didLoadCurrentHealth)
            }
        }
    }
}

public extension HealthModel {
    func isSettingTypeFromHealthKit(_ type: HealthType) -> Bool {
        typesBeingSetFromHealthKit.contains(type)
    }
    
    func startSettingTypeFromHealthKit(_ type: HealthType) {
        guard !isSettingTypeFromHealthKit(type) else { return }
        typesBeingSetFromHealthKit.append(type)
    }
    
    func stopSettingTypeFromHealthKit(_ type: HealthType) {
        guard isSettingTypeFromHealthKit(type) else { return }
        typesBeingSetFromHealthKit.removeAll(where: { $0 == type })
    }
    
    var isSettingMaintenanceFromHealthKit: Bool {
        if health.energyBurnIsCalculated, isSettingTypeFromHealthKit(.energyBurn) {
            return true
        } else if !(health.energyBurnIsCalculated && health.energyBurnCalculatedValue != nil) {
            return isSettingTypeFromHealthKit(.restingEnergy) || isSettingTypeFromHealthKit(.activeEnergy)
        }
        return false
    }
}

public extension HealthModel {

    func updateHealthValues() async throws {
        /// Set the model to ignore changes so that it doesn't redudantly fetch health twice (in `handleChanges`)
        ignoreChanges = true

        try await setFromHealthKit()

        /// Now turn off this flag so that manual user changes are handled appropriately
        ignoreChanges = false
    }
}

//MARK: - Set Units

public extension HealthModel {
    func setHeightUnit(_ newValue: HeightUnit, whileEditing type: HealthType? = nil) {
        
        Task {
            switch heightSource {
            case .healthKit:
                break
//                try await setHeightFromHealthKit(using: newValue)
            case .userEntered:
                await MainActor.run {
                    if type != .height, let value = health.height?.quantity?.value {
                        let converted = health.heightUnit.convert(value, to: newValue)
                        health.height?.quantity?.value = converted
                    }
                }
            }
            
            await MainActor.run {
                health.heightUnit = newValue
            }
        }
    }

    func setEnergyUnit(_ newValue: EnergyUnit, whileEditing type: HealthType? = nil) {
        
        Task {
            switch restingEnergySource {
            case .healthKit:
//                try await setRestingEnergyFromHealthKit(using: newValue)
                break
            case .equation:
                break
            case .userEntered:
                //TODO: Convert
                break
//                await MainActor.run {
//                    if type != .weight, let value = health.weight?.quantity?.value {
//                        let converted = bodyMassUnit.convert(value, to: newValue)
//                        health.weight?.quantity?.value = converted
//                    }
//                }
            }
            
            switch activeEnergySource {
            case .healthKit:
                break
//                try await setActiveEnergyFromHealthKit(using: newValue)
            case .activityLevel:
                break
            case .userEntered:
                //TODO: Convert
                break
//                await MainActor.run {
//                    if type != .leanBodyMass, let value = health.leanBodyMass?.quantity?.value {
//                        let converted = bodyMassUnit.convert(value, to: newValue)
//                        health.leanBodyMass?.quantity?.value = converted
//                    }
//                }
            }
            
            await MainActor.run {
                health.energyUnit = newValue
            }
        }
    }
    
    func setBodyMassUnit(_ newValue: BodyMassUnit, whileEditing type: HealthType? = nil) {
        
        Task {
            switch weightSource {
            case .healthKit:
                break
//                try await setWeightFromHealthKit(using: newValue)
            case .userEntered:
                await MainActor.run {
                    if type != .weight, let value = health.weight?.quantity?.value {
                        let converted = health.bodyMassUnit.convert(value, to: newValue)
                        health.weight?.quantity?.value = converted
                    }
                }
            }
            
            switch leanBodyMassSource {
            case .healthKit:
                break
//                try await setLeanBodyMassFromHealthKit(using: newValue)
            case .equation, .fatPercentage:
                break
            case .userEntered:
                await MainActor.run {
                    if type != .leanBodyMass, let value = health.leanBodyMass?.quantity?.value {
                        let converted = health.bodyMassUnit.convert(value, to: newValue)
                        health.leanBodyMass?.quantity?.value = converted
                    }
                }
            }
            
            await MainActor.run {
                health.bodyMassUnit = newValue
            }
        }
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
