import SwiftUI

struct ContentView: View {
    let dataSource: TimingDataSource
    @State private var selectedTab: Tab = .live

    enum Tab: String, CaseIterable {
        case live = "Live"
        case sessions = "Sessions"
        case settings = "Settings"

        var systemImage: String {
            switch self {
            case .live: "timer"
            case .sessions: "calendar"
            case .settings: "gearshape"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            TimingView(dataSource: dataSource)
                .tabItem {
                    Label(Tab.live.rawValue, systemImage: Tab.live.systemImage)
                }
                .tag(Tab.live)

            SessionListView()
                .tabItem {
                    Label(Tab.sessions.rawValue, systemImage: Tab.sessions.systemImage)
                }
                .tag(Tab.sessions)

            SettingsView()
                .tabItem {
                    Label(Tab.settings.rawValue, systemImage: Tab.settings.systemImage)
                }
                .tag(Tab.settings)
        }
        .tint(.red) // F1 brand red
    }
}
