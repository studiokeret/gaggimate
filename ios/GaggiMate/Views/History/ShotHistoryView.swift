import SwiftUI

struct ShotHistoryView: View {
    @EnvironmentObject var service: WebSocketService

    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Shot History",
                systemImage: "clock.arrow.circlepath",
                description: Text("Shot history is stored on the GaggiMate device.\nAccess it through the web interface for full analysis with charts and detailed shot data.")
            )
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    if service.isConnected {
                        Link(destination: URL(string: "http://\(service.hostAddress)/history")!) {
                            Label("Open Web", systemImage: "safari")
                        }
                    }
                }
            }
        }
    }
}
