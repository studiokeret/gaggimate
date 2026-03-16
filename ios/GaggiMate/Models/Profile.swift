import Foundation

struct Profile: Codable, Identifiable {
    let id: String
    var label: String
    var type: ProfileType
    var description: String
    var temperature: Double?
    var favorite: Bool?
    var selected: Bool?
    var phases: [Phase]?

    enum ProfileType: String, Codable {
        case standard
        case pro
    }
}

struct Phase: Codable, Identifiable {
    var id: String { name + String(duration) }
    var name: String
    var phase: PhaseType
    var valve: Int
    var duration: Double
    var pump: PumpValue?
    var transition: Transition?
    var temperature: Double?
    var targets: [PhaseTarget]?

    enum PhaseType: String, Codable {
        case preinfusion
        case brew
    }
}

enum PumpValue: Codable {
    case simple(Double)
    case advanced(PumpSettings)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Double.self) {
            self = .simple(value)
        } else if let settings = try? container.decode(PumpSettings.self) {
            self = .advanced(settings)
        } else {
            self = .simple(0)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .simple(let value):
            try container.encode(value)
        case .advanced(let settings):
            try container.encode(settings)
        }
    }
}

struct PumpSettings: Codable {
    var target: String
    var pressure: Double
    var flow: Double
}

struct Transition: Codable {
    var type: TransitionType
    var duration: Double
    var adaptive: Int?

    enum TransitionType: String, Codable {
        case instant
        case linear
        case easeIn = "ease-in"
        case easeOut = "ease-out"
        case easeInOut = "ease-in-out"
    }
}

struct PhaseTarget: Codable {
    var type: TargetType
    var value: Double
    var `operator`: TargetOperator?

    enum TargetType: String, Codable {
        case volumetric
        case pressure
        case flow
        case pumped
    }

    enum TargetOperator: String, Codable {
        case gte
        case lte
    }
}
