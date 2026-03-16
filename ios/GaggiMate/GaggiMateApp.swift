import SwiftUI

@main
struct GaggiMateApp: App {
    @StateObject private var webSocketService = WebSocketService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(webSocketService)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var service: WebSocketService

    var body: some View {
        Group {
            if service.hostAddress.isEmpty {
                ConnectionSetupView()
            } else {
                MainTabView()
            }
        }
        .onAppear {
            if !service.hostAddress.isEmpty {
                service.connect()
            }
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var service: WebSocketService

    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "gauge.open.with.lines.needle.33percent")
                }

            ProfileListView()
                .tabItem {
                    Label("Profiles", systemImage: "list.bullet")
                }

            ShotHistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }

            ConnectionSettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .tint(.brown)
    }
}
