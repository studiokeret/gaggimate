import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var service: WebSocketService
    @State private var brewElapsed: TimeInterval = 0
    @State private var brewStartTime: Date?
    @State private var brewTimer: Timer?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ConnectionBanner(isConnected: service.isConnected)

                    TemperatureGaugeView(
                        current: service.status.currentTemperature,
                        target: service.status.targetTemperature
                    )

                    LiveStatsGrid(status: service.status)

                    ModeControlView(
                        currentMode: service.status.mode,
                        onModeChange: { mode in
                            service.changeMode(mode)
                        }
                    )

                    if !service.status.selectedProfile.isEmpty {
                        ActiveProfileCard(
                            profileName: service.status.selectedProfile,
                            mode: service.status.mode,
                            brewElapsed: brewElapsed
                        )
                    }

                    if !service.statusHistory.isEmpty {
                        TemperatureChartView(history: service.statusHistory)
                    }
                }
                .padding()
            }
            .navigationTitle("GaggiMate")
            .refreshable {
                service.reconnect()
            }
        }
        .onChange(of: service.status.mode) { _, newMode in
            if newMode == .brew {
                startBrewTimer()
            } else {
                stopBrewTimer()
            }
        }
    }

    private func startBrewTimer() {
        brewStartTime = Date()
        brewElapsed = 0
        brewTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            Task { @MainActor in
                guard let start = brewStartTime else { return }
                brewElapsed = Date().timeIntervalSince(start)
            }
        }
    }

    private func stopBrewTimer() {
        brewTimer?.invalidate()
        brewTimer = nil
    }
}

// MARK: - Connection Banner

struct ConnectionBanner: View {
    let isConnected: Bool

    var body: some View {
        HStack {
            Image(systemName: isConnected ? "wifi" : "wifi.slash")
                .foregroundStyle(isConnected ? .green : .red)
            Text(isConnected ? "Connected" : "Disconnected")
                .font(.subheadline)
                .foregroundStyle(isConnected ? .secondary : .red)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isConnected ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
        )
    }
}

// MARK: - Live Stats

struct LiveStatsGrid: View {
    let status: MachineStatus

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
        ], spacing: 12) {
            StatCard(
                title: "Pressure",
                value: String(format: "%.1f", status.currentPressure),
                unit: "bar",
                icon: "gauge.with.needle"
            )
            StatCard(
                title: "Flow",
                value: String(format: "%.1f", status.currentFlow),
                unit: "ml/s",
                icon: "drop.fill"
            )
            StatCard(
                title: "Weight",
                value: String(format: "%.1f", status.currentWeight),
                unit: "g",
                icon: "scalemass.fill"
            )
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.brown)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .monospacedDigit()
            Text(unit)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - Active Profile Card

struct ActiveProfileCard: View {
    let profileName: String
    let mode: MachineMode
    let brewElapsed: TimeInterval

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "cup.and.saucer.fill")
                    .foregroundStyle(.brown)
                Text("Active Profile")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                if mode == .brew {
                    Text(formatTime(brewElapsed))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .monospacedDigit()
                        .foregroundStyle(.brown)
                }
            }
            Text(profileName)
                .font(.title3)
                .fontWeight(.semibold)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let seconds = Int(interval)
        let tenths = Int((interval - Double(seconds)) * 10)
        return String(format: "%d.%d s", seconds, tenths)
    }
}
