import SwiftUI

struct ModeControlView: View {
    let currentMode: MachineMode
    let onModeChange: (MachineMode) -> Void

    private let modes: [MachineMode] = [.standby, .brew, .steam, .water]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Machine Mode")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                ForEach(modes, id: \.rawValue) { mode in
                    ModeButton(
                        mode: mode,
                        isActive: currentMode == mode,
                        action: { onModeChange(mode) }
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

struct ModeButton: View {
    let mode: MachineMode
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: mode.icon)
                    .font(.title2)
                Text(mode.label)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isActive ? Color.brown : Color.clear)
            )
            .foregroundStyle(isActive ? .white : .primary)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isActive)
    }
}
