import SwiftUI
import SwiftSugar

let LogStartDate = Date(fromDateString: "2024_01_01")!
//let LogStartDate = Date(fromDateString: "2023_12_01")!
//let LogStartDate = Date(fromDateString: "2022_01_01")!
//let LogStartDate = Date.now.startOfDay
//let DaysStartDate = Date(fromDateString: "2016_01_01")!

public struct SettingsDemoView: View {
    
    @State var provider: Provider = Provider.shared
    
    @State var pastDateBeingShown: Date? = nil
    @State var showingSettings = false

    @AppStorage("initialLaunchCompleted") var initialLaunchCompleted: Bool = false
    
    public init() { }
    
    public var body: some View {
        NavigationView {
            List {
                settingsSection
                healthDetailsSection
            }
            .navigationTitle("Demo")
            .toolbar { toolbarContent }
        }
        .sheet(item: $pastDateBeingShown) { healthDetailsForm(for: $0) }
        .sheet(isPresented: $showingSettings) { settingsForm }
        .onAppear(perform: appeared)
    }
    
    //TODO: Rewrite these
    func appeared() {
        //TODO: Replicate these in Prep
//        Task {
//            let settings = await fetchSettingsFromDocuments()
//            await MainActor.run {
//                self.settingsProvider.settings = settings
//            }
//
//            if initialLaunchCompleted  {
//                try await HealthStore.requestPermissions()
//                try await Provider.syncWithHealthKitAndRecalculateAllDays()
//            } else {
//                resetData()
//            }
//
//            if let daysStartDate = await DayProvider.fetchBackendDaysStartDate() {
//                let numberOfDays = LogStartDate.numberOfDaysFrom(daysStartDate)
//                guard numberOfDays > 0 else { return }
//                var preLogDates: [Date] = []
//
//                /// For each date from DaysStartDate till the day before LogStartDate, check if we have a Day for it, and if so append the date
//                for i in 0..<numberOfDays {
//                    let date = daysStartDate.moveDayBy(i)
//                    if let _ = await fetchDayFromDocuments(date) {
//                        preLogDates.append(date)
//                    }
//                }
//                await MainActor.run { [preLogDates] in
//                    self.preLogDates = preLogDates
//                }
//            }
//        }
    }
    
    func resetData() {
//        deleteAllFilesInDocuments()
//
//        Task {
//            var settings = await fetchSettingsFromDocuments()
//            settings.setHealthKitSyncing(for: .weight, to: true)
//            settings.setHealthKitSyncing(for: .height, to: true)
//            settings.setHealthKitSyncing(for: .leanBodyMass, to: true)
//            settings.setHealthKitSyncing(for: .fatPercentage, to: true)
//            await saveSettingsInDocuments(settings)
//
//            await MainActor.run { [settings] in
//                self.settingsProvider.settings = settings
//            }
//
//            let start = CFAbsoluteTimeGetCurrent()
//            let _ = await fetchAllDaysFromDocuments(
//                from: LogStartDate,
//                createIfNotExisting: true
//            )
//            print("Created all days in: \(CFAbsoluteTimeGetCurrent()-start)s")
//
//            try await Provider.syncWithHealthKitAndRecalculateAllDays()
//
//            initialLaunchCompleted = true
//        }
    }
    
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button("Reset Data") {
                    resetData()
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }
    
    var settingsForm: some View {
        SettingsForm(provider, isPresented: $showingSettings)
    }
    
    func healthDetailsForm(for date: Date) -> some View {
        MockHealthDetailsForm(
            date: date,
            isPresented: Binding<Bool>(
                get: { true },
                set: { if !$0 { pastDateBeingShown = nil } }
            )
        )
    }
    
    var healthDetailsSection: some View {
        
        let numberOfDays = Date.now.numberOfDaysFrom(LogStartDate)
        
        return Section("Health Details") {
            ForEach(0...numberOfDays, id: \.self) {
                button(Date.now.moveDayBy(-$0))
            }
        }
    }
    
    func button(_ date: Date) -> some View {
        return Button {
            pastDateBeingShown = date
        } label: {
            Text(date.shortDateString + "\(date.isToday ? " (Current)" : "")")
        }
    }
    
    @State var preLogDates: [Date] = []
    
    var preLogHealthDetailsSection: some View {
        Section("Pre-Log Health Details") {
            ForEach(preLogDates, id: \.self) {
                button($0)
            }
        }
    }
    var settingsSection: some View {
        Section {
            Button {
                showingSettings = true
            } label: {
                Text("Settings")
            }
        }
    }
}

#Preview("SettingsDemoView") {
    SettingsDemoView()
}

let MockPastDate = Date.now.moveDayBy(-3)

extension Date: Identifiable {
    public var id: Date { return self }
}

import SwiftUI

struct MockHealthDetailsForm: View {
    
    @State var provider: Provider? = nil
    @Binding var isPresented: Bool
    
    let date: Date
    
    init(
        date: Date,
        isPresented: Binding<Bool> = .constant(true)
    ) {
        self.date = date
        _isPresented = isPresented
    }

    var body: some View {
        if let provider {
            HealthDetailsForm(
                provider: provider,
                isPresented: $isPresented
            )
        } else {
            Color.clear
                .onAppear {
                    Task {
                        let healthDetails = await fetchOrCreateHealthDetailsFromDocuments(date)
                        let provider = Provider()
                        provider.healthDetails = healthDetails
                        await MainActor.run {
                            self.provider = provider
                        }
                    }
                }
        }
    }
}

//MARK: Reusable

func deleteAllFilesInDocuments() {
    do {
        let fileURLs = try FileManager.default.contentsOfDirectory(
            at: getDocumentsDirectory(),
            includingPropertiesForKeys: nil,
            options: .skipsHiddenFiles
        )
        for fileURL in fileURLs {
            try FileManager.default.removeItem(at: fileURL)
        }
    } catch  {
        print(error)
    }
}

func getDocumentsDirectory() -> URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
}

import PrepShared

func fetchOrCreateDayFromDocuments(_ date: Date) async -> Day {
    let filename = "\(date.dateString).json"
    let url = getDocumentsDirectory().appendingPathComponent(filename)
    do {
        let data = try Data(contentsOf: url)
        let day = try JSONDecoder().decode(Day.self, from: data)
        return day
    } catch {
        //TODO: Rewrite
//        let day = Day(date: date)
        let day = Day(dateString: Date.now.dateString)
        await saveDayInDocuments(day)
        return day
    }
}

func fetchAllPreLogDaysFromDocuments() async -> [Date : Day] {
    guard let daysStartDate = await DayProvider.fetchBackendDaysStartDate() else {
        return [:]
    }
    let logStartDate = await DayProvider.fetchBackendLogStartDate()
    return await fetchAllDaysFromDocuments(
        from: daysStartDate,
        to: logStartDate,
        createIfNotExisting: false
    )
}

func fetchAllDaysFromDocuments(
    from startDate: Date,
    to endDate: Date = Date.now,
    createIfNotExisting: Bool
) async -> [Date : Day] {
    //TODO: In production:
    /// [ ] Optimizing by not fetching the meals etc, only fetching fields we need
    var days: [Date : Day] = [:]
    for i in (0...endDate.numberOfDaysFrom(startDate)).reversed() {
        let date = endDate.moveDayBy(-i)
        let day = if createIfNotExisting {
            await fetchOrCreateDayFromDocuments(date)
        } else {
            await fetchDayFromDocuments(date)
        }
        if let day {
            days[date.startOfDay] = day
        }
    }
    return days
}

func _fetchAllDaysFromDocuments(
    from startDate: Date,
    to endDate: Date = Date.now,
    createIfNotExisting: Bool
) async -> [Day] {
    //TODO: In production:
    /// [ ] Optimizing by not fetching the meals etc, only fetching fields we need
    var days: [Day] = []
    for i in (0...endDate.numberOfDaysFrom(startDate)).reversed() {
        let date = endDate.moveDayBy(-i)
        let day = if createIfNotExisting {
            await fetchOrCreateDayFromDocuments(date)
        } else {
            await fetchDayFromDocuments(date)
        }
        if let day {
            days.append(day)
        }
    }
    return days
}

func fetchDayFromDocuments(_ date: Date) async -> Day? {
    let filename = "\(date.dateString).json"
    let url = getDocumentsDirectory().appendingPathComponent(filename)
    do {
        let data = try Data(contentsOf: url)
        let day = try JSONDecoder().decode(Day.self, from: data)
        return day
    } catch {
        return nil
    }
}

func saveDayInDocuments(_ day: Day) async {
    let date = day.date
    do {
        let filename = "\(date.dateString).json"
        let url = getDocumentsDirectory().appendingPathComponent(filename)
        let json = try JSONEncoder().encode(day)
        try json.write(to: url)
    } catch {
        fatalError()
    }
}

func fetchOrCreateHealthDetailsFromDocuments(_ date: Date) async -> HealthDetails {
    let day = await fetchOrCreateDayFromDocuments(date)
    let healthDetails = day.healthDetails
//    guard let healthDetails = day.healthDetails else {
//        let healthDetails = HealthDetails(date: date)
//        day.healthDetails = healthDetails
//        await saveDayInDocuments(day)
//        return healthDetails
//    }
    return healthDetails
}

func fetchHealthDetailsFromDocuments(_ date: Date) async -> HealthDetails? {
    await fetchDayFromDocuments(date)?.healthDetails
}

func saveHealthDetailsInDocuments(_ healthDetails: HealthDetails) async throws {
    var day = await fetchOrCreateDayFromDocuments(healthDetails.date)
    try Task.checkCancellation()
    day.healthDetails = healthDetails
    await saveDayInDocuments(day)
}

func fetchSettingsFromDocuments() async -> Settings {
    let filename = "settings.json"
    let url = getDocumentsDirectory().appendingPathComponent(filename)
    do {
        let data = try Data(contentsOf: url)
        let settings = try JSONDecoder().decode(Settings.self, from: data)
        return settings
    } catch {
        let settings = Settings.default
        await saveSettingsInDocuments(settings)
        return settings
    }
}

func saveSettingsInDocuments(_ settings: Settings) async {
    do {
        let filename = "settings.json"
        let url = getDocumentsDirectory().appendingPathComponent(filename)
        let json = try JSONEncoder().encode(settings)
        try json.write(to: url)
    } catch {
        fatalError()
    }
}
