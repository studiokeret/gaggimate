import SwiftUI
import Charts

struct TemperatureChartView: View {
    let history: [StatusHistoryEntry]

    private var recentHistory: [StatusHistoryEntry] {
        Array(history.suffix(120))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Temperature & Pressure")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Chart {
                ForEach(recentHistory) { entry in
                    LineMark(
                        x: .value("Time", entry.timestamp),
                        y: .value("Temperature", entry.temperature),
                        series: .value("Series", "Temperature")
                    )
                    .foregroundStyle(.orange)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                }

                ForEach(recentHistory) { entry in
                    LineMark(
                        x: .value("Time", entry.timestamp),
                        y: .value("Pressure", entry.pressure * 10),
                        series: .value("Series", "Pressure")
                    )
                    .foregroundStyle(.blue)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                    AxisValueLabel(format: .dateTime.minute().second())
                }
            }
            .chartLegend(position: .bottom) {
                HStack(spacing: 16) {
                    Label("Temp (°C)", systemImage: "circle.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                    Label("Pressure (bar×10)", systemImage: "circle.fill")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
            }
            .frame(height: 200)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}
