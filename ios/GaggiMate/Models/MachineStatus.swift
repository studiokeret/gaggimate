import Foundation

enum MachineMode: Int, Codable, CaseIterable {
    case standby = 0
    case brew = 1
    case steam = 2
    case water = 3
    case grind = 4

    var label: String {
        switch self {
        case .standby: return "Standby"
        case .brew: return "Brew"
        case .steam: return "Steam"
        case .water: return "Water"
        case .grind: return "Grind"
        }
    }

    var icon: String {
        switch self {
        case .standby: return "moon.fill"
        case .brew: return "cup.and.saucer.fill"
        case .steam: return "cloud.fill"
        case .water: return "drop.fill"
        case .grind: return "gearshape.2.fill"
        }
    }
}

struct MachineStatus {
    var connected: Bool = false
    var currentTemperature: Double = 0
    var targetTemperature: Double = 0
    var currentPressure: Double = 0
    var targetPressure: Double = 0
    var currentFlow: Double = 0
    var currentWeight: Double = 0
    var targetWeight: Double = 0
    var mode: MachineMode = .standby
    var selectedProfile: String = ""
    var selectedProfileId: String?
    var brewTargetDuration: Double = 0
    var volumetricAvailable: Bool = false
    var bluetoothConnected: Bool = false
    var hasPressure: Bool = false
    var hasDimming: Bool = false
    var process: BrewProcess?
    var timestamp: Date = Date()
}

struct BrewProcess: Codable {
    let a: Bool?  // active
    let p: Int?   // phase index
    let d: Double? // duration
}

struct StatusHistoryEntry: Identifiable {
    let id = UUID()
    let timestamp: Date
    let temperature: Double
    let pressure: Double
    let flow: Double
    let weight: Double
}
