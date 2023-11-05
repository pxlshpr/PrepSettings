import Foundation

public extension Notification.Name {
    static var didLoadCurrentBiometrics: Notification.Name { .init("didLoadCurrentBiometrics") }
    static var didSaveBiometrics: Notification.Name { .init("didSaveBiometrics") }
}

