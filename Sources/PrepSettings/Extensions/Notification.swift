import Foundation

public extension Notification.Name {
    static var didLoadCurrentHealth: Notification.Name { .init("didLoadCurrentHealth") }
    static var didSaveHealth: Notification.Name { .init("didSaveHealth") }
}

public extension Notification {
    enum PrepSettingsKeys: String {
        case date = "date"
    }
}

public func post(_ name: Notification.Name, _ userInfo: [Notification.PrepSettingsKeys : Any]) {
    NotificationCenter.default.post(name: name, object: nil, userInfo: userInfo)
}

extension Notification {
    func value(for key: Notification.PrepSettingsKeys) -> Any? {
        userInfo?[key]
    }
    
    var date: Date? {
        value(for: PrepSettingsKeys.date) as? Date
    }
}
