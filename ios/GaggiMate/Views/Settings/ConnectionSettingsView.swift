import SwiftUI

struct ConnectionSettingsView: View {
    @EnvironmentObject var service: WebSocketService
    @State private var hostInput = ""
    @State private var showingResetAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Image(systemName: service.isConnected ? "wifi" : "wifi.slash")
                            .foregroundStyle(service.isConnected ? .green : .red)
                            .font(.title2)
                        VStack(alignment: .leading) {
                            Text(service.isConnected ? "Connected" : "Disconnected")
                                .font(.headline)
                            if service.isConnected {
                                Text(service.hostAddress)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Connection Status")
                }

                Section {
                    TextField("IP Address or Hostname", text: $hostInput)
                        .textContentType(.URL)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)

                    Button("Connect") {
                        service.hostAddress = hostInput
                    }
                    .disabled(hostInput.isEmpty)

                    if service.isConnected {
                        Button("Reconnect") {
                            service.reconnect()
                        }
                    }
                } header: {
                    Text("GaggiMate Address")
                } footer: {
                    Text("Enter the IP address or hostname of your GaggiMate device. Example: 192.168.1.100 or gaggimate.local")
                }

                if service.isConnected {
                    Section("Machine Info") {
                        LabeledContent("Mode", value: service.status.mode.label)
                        LabeledContent("Profile", value: service.status.selectedProfile.isEmpty ? "None" : service.status.selectedProfile)
                        LabeledContent("Temperature", value: String(format: "%.1f°C", service.status.currentTemperature))
                        if service.status.hasPressure {
                            LabeledContent("Pressure", value: String(format: "%.1f bar", service.status.currentPressure))
                        }
                        if service.status.bluetoothConnected {
                            LabeledContent("Scale", value: "Connected")
                        }
                    }

                    Section("Web Interface") {
                        Link(destination: URL(string: "http://\(service.hostAddress)")!) {
                            HStack {
                                Label("Open Web Dashboard", systemImage: "safari")
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Section {
                    Button("Disconnect", role: .destructive) {
                        service.disconnect()
                        hostInput = ""
                        service.hostAddress = ""
                    }
                    .disabled(!service.isConnected && service.hostAddress.isEmpty)
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                hostInput = service.hostAddress
            }
        }
    }
}

struct ConnectionSetupView: View {
    @EnvironmentObject var service: WebSocketService
    @State private var hostInput = ""

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "cup.and.saucer.fill")
                .font(.system(size: 80))
                .foregroundStyle(.brown)

            Text("GaggiMate")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Connect to your espresso machine")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(spacing: 16) {
                TextField("IP Address or Hostname", text: $hostInput)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.URL)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
                    .padding(.horizontal, 32)

                Button(action: {
                    service.hostAddress = hostInput
                }) {
                    Text("Connect")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.brown)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(hostInput.isEmpty)
                .padding(.horizontal, 32)
            }

            Text("Enter the IP address of your GaggiMate device\ne.g. 192.168.1.100")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
    }
}
