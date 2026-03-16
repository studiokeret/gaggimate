import SwiftUI

struct TemperatureGaugeView: View {
    let current: Double
    let target: Double

    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(current / target, 1.5)
    }

    private var temperatureColor: Color {
        if current < target * 0.9 {
            return .blue
        } else if current < target * 1.05 {
            return .green
        } else {
            return .red
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Background arc
                Circle()
                    .trim(from: 0.15, to: 0.85)
                    .stroke(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .rotationEffect(.degrees(90))

                // Progress arc
                Circle()
                    .trim(from: 0.15, to: 0.15 + min(progress * 0.7, 0.7))
                    .stroke(
                        temperatureColor.gradient,
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .rotationEffect(.degrees(90))
                    .animation(.easeInOut(duration: 0.5), value: current)

                // Temperature display
                VStack(spacing: 2) {
                    Text(String(format: "%.1f", current))
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(temperatureColor)
                    Text("°C")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 4) {
                        Image(systemName: "target")
                            .font(.caption)
                        Text(String(format: "%.0f°C", target))
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                }
            }
            .frame(height: 200)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
}
