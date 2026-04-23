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
        }
        .modelContainer(container)
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
