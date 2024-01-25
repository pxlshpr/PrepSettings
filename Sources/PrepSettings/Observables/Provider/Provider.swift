import SwiftUI
import PrepShared

public typealias SettingsFetchHandler = (() async throws -> Settings)
public typealias SettingsSaveHandler = ((Settings) async throws -> ())

public typealias DayFetchOrCreateHandler = ((Date) async throws -> Day)
public typealias DaySaveHandler = ((Day) async throws -> ())

@Observable public class Provider {

    public static let shared = Provider()

    public var settings: Settings = .default

    public var _displayedDate: Date
    public var displayedDay: Day
    public var today: Day
    var previousToday: Day
    
    var daySaveTask: Task<Void, Error>? = nil
    var displayedDayChangeTask: Task<Void, Error>? = nil

    var handlers: ProviderHandlers? = nil

    public init() {
        //TODO: Store these in UserDefaults too for quick access
        let day = Day(dateString: Date.now.dateString)
        self.displayedDay = day
        self._displayedDate = day.date
        self.today = day
        self.previousToday = day
        
        if let settings = UserDefaults.settings {
            self.settings = settings
        }
    }
}

public struct ProviderHandlers {
    public struct SettingsHandlers {
        public var fetch: SettingsFetchHandler
        public var save: SettingsSaveHandler

        public init(
            fetch: @escaping SettingsFetchHandler,
            save: @escaping SettingsSaveHandler
        ) {
            self.fetch = fetch
            self.save = save
        }
    }
    
    public struct DayHandlers {
        public var fetchOrCreate: DayFetchOrCreateHandler
        public var save: DaySaveHandler
        
        public init(
            fetchOrCreate: @escaping DayFetchOrCreateHandler,
            save: @escaping DaySaveHandler
        ) {
            self.fetchOrCreate = fetchOrCreate
            self.save = save
        }
    }
    
    public var settings: SettingsHandlers
    public var day: DayHandlers
    
    public init(
        settings: SettingsHandlers,
        day: DayHandlers
    ) {
        self.settings = settings
        self.day = day
    }
}

public extension Provider {
    
    static func configure(handlers: ProviderHandlers) {
        shared.configure(handlers: handlers)
    }
    
    static func saveSettings() {
        shared.saveSettings()
    }
    
    static func fetchSettings() {
        shared.fetchSettings()
    }
}

extension Provider {
    
    func configure(handlers: ProviderHandlers) {
        self.handlers = handlers
        fetchSettings()
    }

    func saveSettings() {
        guard let save = handlers?.settings.save else { return }
        Task.detached(priority: .background) {
            
            /// Save in the backend
            try await save(self.settings)
            
            /// Also save in UserDefaults for quick access on init
            self.saveSettingsToUserDefaults()
        }
    }
    
    func saveSettingsToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(self.settings) {
            UserDefaults.standard.set(encoded, forKey: "Settings")
        }
    }
    
    func fetchSettings() {
        guard let fetch = handlers?.settings.fetch else { return }
        Task {
            let settings = try await fetch()
            await MainActor.run {
                let hasChanged = settings != self.settings
                self.settings = settings
                
                /// Crucial to do this only **after** setting `settings`, otherwise the notification observers will act on the stale settings
                if hasChanged {
                    saveSettingsToUserDefaults()
                    post(.didUpdateSettings)
                }
            }
        }
    }
}

extension UserDefaults {
    static var settings: Settings? {
        guard let data = UserDefaults.standard.object(forKey: "Settings") as? Data else {
            return nil
        }
        return try? JSONDecoder().decode(Settings.self, from: data)
    }
}
