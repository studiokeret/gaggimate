import Foundation
import Combine

@MainActor
class WebSocketService: ObservableObject {
    @Published var isConnected = false
    @Published var status = MachineStatus()
    @Published var statusHistory: [StatusHistoryEntry] = []

    private var webSocketTask: URLSessionWebSocketTask?
    private var session: URLSession
    private var reconnectAttempts = 0
    private let maxReconnectDelay: TimeInterval = 30
    private let baseReconnectDelay: TimeInterval = 1
    private var reconnectWorkItem: DispatchWorkItem?
    private var pendingRequests: [String: CheckedContinuation<Data, Error>] = [:]
    private let maxHistoryEntries = 600

    var hostAddress: String {
        didSet {
            UserDefaults.standard.set(hostAddress, forKey: "gaggiMateHost")
            reconnect()
        }
    }

    init() {
        self.session = URLSession(configuration: .default)
        self.hostAddress = UserDefaults.standard.string(forKey: "gaggiMateHost") ?? ""
    }

    func connect() {
        guard !hostAddress.isEmpty else { return }
        disconnect()

        let urlString = "ws://\(hostAddress)/ws"
        guard let url = URL(string: urlString) else { return }

        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        receiveMessage()

        isConnected = false
        // Connection confirmed when we receive first status message
        reconnectAttempts = 0
    }

    func disconnect() {
        reconnectWorkItem?.cancel()
        reconnectWorkItem = nil
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        isConnected = false
        status.connected = false
    }

    func reconnect() {
        disconnect()
        connect()
    }

    // MARK: - Send Messages

    func send<T: Encodable>(_ message: T) {
        guard let data = try? JSONEncoder().encode(message),
              let string = String(data: data, encoding: .utf8) else { return }
        webSocketTask?.send(.string(string)) { error in
            if let error {
                print("WebSocket send error: \(error)")
            }
        }
    }

    func request<T: Encodable, R: Decodable>(_ message: T, responseType: String) async throws -> R {
        let rid = UUID().uuidString
        // Encode with rid injected
        guard var dict = try? JSONSerialization.jsonObject(with: JSONEncoder().encode(message)) as? [String: Any] else {
            throw WebSocketError.encodingFailed
        }
        dict["rid"] = rid

        let data = try JSONSerialization.data(withJSONObject: dict)
        guard let string = String(data: data, encoding: .utf8) else {
            throw WebSocketError.encodingFailed
        }

        return try await withCheckedThrowingContinuation { continuation in
            pendingRequests[rid] = continuation as! CheckedContinuation<Data, Error>

            webSocketTask?.send(.string(string)) { [weak self] error in
                if let error {
                    Task { @MainActor in
                        self?.pendingRequests.removeValue(forKey: rid)
                    }
                    continuation.resume(throwing: error)
                }
            }

            // Timeout after 30 seconds
            Task { @MainActor [weak self] in
                try? await Task.sleep(nanoseconds: 30_000_000_000)
                if let cont = self?.pendingRequests.removeValue(forKey: rid) {
                    cont.resume(throwing: WebSocketError.timeout)
                }
            }
        }
    }

    func changeMode(_ mode: MachineMode) {
        send(ChangeModeRequest(mode: mode.rawValue))
    }

    func listProfiles() {
        send(ProfilesListRequest(rid: UUID().uuidString))
    }

    func selectProfile(id: String) {
        send(ProfilesSelectRequest(rid: UUID().uuidString, id: id))
    }

    func favoriteProfile(id: String, favorite: Bool) {
        let tp = favorite ? "req:profiles:favorite" : "req:profiles:unfavorite"
        send(ProfilesFavoriteRequest(tp: tp, rid: UUID().uuidString, id: id))
    }

    // MARK: - Receive Messages

    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success(let message):
                    switch message {
                    case .string(let text):
                        self?.handleMessage(text)
                    case .data(let data):
                        if let text = String(data: data, encoding: .utf8) {
                            self?.handleMessage(text)
                        }
                    @unknown default:
                        break
                    }
                    self?.receiveMessage()
                case .failure(let error):
                    print("WebSocket receive error: \(error)")
                    self?.handleDisconnect()
                }
            }
        }
    }

    private func handleMessage(_ text: String) {
        guard let data = text.data(using: .utf8) else { return }

        // Check for type field
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let tp = json["tp"] as? String else { return }

        // Handle pending request responses
        if let rid = json["rid"] as? String, let continuation = pendingRequests.removeValue(forKey: rid) {
            continuation.resume(returning: data)
            return
        }

        switch tp {
        case "evt:status":
            handleStatusMessage(data)
        case "res:profiles:list":
            NotificationCenter.default.post(
                name: .profilesListReceived,
                object: nil,
                userInfo: ["data": data]
            )
        default:
            break
        }
    }

    private func handleStatusMessage(_ data: Data) {
        guard let msg = try? JSONDecoder().decode(StatusMessage.self, from: data) else { return }

        if !isConnected {
            isConnected = true
        }

        status = MachineStatus(
            connected: true,
            currentTemperature: msg.ct ?? 0,
            targetTemperature: msg.tt ?? 0,
            currentPressure: msg.pr ?? 0,
            targetPressure: msg.pt ?? 0,
            currentFlow: msg.fl ?? 0,
            currentWeight: msg.cw ?? 0,
            targetWeight: msg.tw ?? 0,
            mode: MachineMode(rawValue: msg.m ?? 0) ?? .standby,
            selectedProfile: msg.p ?? "",
            selectedProfileId: msg.puid,
            brewTargetDuration: msg.btd ?? 0,
            volumetricAvailable: msg.bta ?? false,
            bluetoothConnected: msg.bc ?? false,
            hasPressure: msg.cp ?? false,
            hasDimming: msg.cd ?? false,
            process: msg.process,
            timestamp: Date()
        )

        let entry = StatusHistoryEntry(
            timestamp: Date(),
            temperature: msg.ct ?? 0,
            pressure: msg.pr ?? 0,
            flow: msg.fl ?? 0,
            weight: msg.cw ?? 0
        )
        statusHistory.append(entry)
        if statusHistory.count > maxHistoryEntries {
            statusHistory.removeFirst(statusHistory.count - maxHistoryEntries)
        }
    }

    private func handleDisconnect() {
        isConnected = false
        status.connected = false
        scheduleReconnect()
    }

    private func scheduleReconnect() {
        reconnectWorkItem?.cancel()
        let delay = min(baseReconnectDelay * pow(2, Double(reconnectAttempts)), maxReconnectDelay)
        reconnectAttempts += 1

        let workItem = DispatchWorkItem { [weak self] in
            Task { @MainActor in
                self?.connect()
            }
        }
        reconnectWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }
}

enum WebSocketError: Error {
    case encodingFailed
    case timeout
    case notConnected
}

extension Notification.Name {
    static let profilesListReceived = Notification.Name("profilesListReceived")
}
