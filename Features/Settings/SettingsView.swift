import SwiftUI

struct SettingsView: View {
    @AppStorage("dataRefreshRate") private var refreshRate: Double = 2.0
    @AppStorage("useDarkMode") private var useDarkMode = true
    @AppStorage("showSectorColors") private var showSectorColors = true
    @AppStorage("enableLiveActivity") private var enableLiveActivity = true
    @AppStorage("enableNotifications") private var enableNotifications = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Data") {
                    HStack {
                        Text("Refresh Rate")
                        Spacer()
                        Text("\(refreshRate, specifier: "%.1f")s")
                            .foregroundColor(.gray)
                    }
                    Slider(value: $refreshRate, in: 0.5...5.0, step: 0.5) {
                        Text("Refresh Rate")
                    }

                    Toggle("Sector Time Colors", isOn: $showSectorColors)
                }

                Section("Live Activity") {
                    Toggle("Show on Lock Screen", isOn: $enableLiveActivity)
                    if enableLiveActivity {
                        Text("Shows top 3 drivers on the Lock Screen and Dynamic Island during active sessions.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                Section("Notifications") {
                    Toggle("Session Start Alerts", isOn: $enableNotifications)
                    if enableNotifications {
                        Text("Get notified 5 minutes before each session starts.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0 (1)")
                            .foregroundColor(.gray)
                    }

                    HStack {
                        Text("Build")
                        Spacer()
                        Text("Debug (Mock Data)")
                            .foregroundColor(.orange)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .preferredColorScheme(useDarkMode ? .dark : .light)
    }
}

#Preview {
    SettingsView()
}
