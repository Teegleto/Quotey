import SwiftUI
import SwiftData

@main
struct QuoteyApp: App {
    let container: ModelContainer

    init() {
        do {
            let schema = Schema([Quote.self, Tag.self, ReviewLog.self])
            let config = ModelConfiguration(
                schema: schema,
                url: QuoteyApp.storeURL(),
                cloudKitDatabase: .automatic
            )
            container = try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .task { await PendingImportDrain.drain(into: container.mainContext) }
        }
        .modelContainer(container)
    }

    static func storeURL() -> URL {
        let fm = FileManager.default
        if let group = fm.containerURL(
            forSecurityApplicationGroupIdentifier: AppGroup.identifier
        ) {
            return group.appendingPathComponent("Quotey.sqlite")
        }
        let docs = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? fm.createDirectory(at: docs, withIntermediateDirectories: true)
        return docs.appendingPathComponent("Quotey.sqlite")
    }
}

enum AppGroup {
    static let identifier = "group.com.quotey.shared"
    static let pendingImportsSubdir = "pending"

    static func pendingImportsDirectory() -> URL? {
        guard let base = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: identifier
        ) else { return nil }
        let dir = base.appendingPathComponent(pendingImportsSubdir, isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }
}

struct RootTabView: View {
    var body: some View {
        TabView {
            QuoteListView()
                .tabItem { Label("Library", systemImage: "text.quote") }
            StudyHomeView()
                .tabItem { Label("Study", systemImage: "brain.head.profile") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}
