import Foundation

// MARK: - Incoming Messages

struct StatusMessage: Decodable {
    let tp: String
    let ct: Double?  // current temperature
    let tt: Double?  // target temperature
    let pr: Double?  // current pressure
    let pt: Double?  // target pressure
    let fl: Double?  // current flow
    let m: Int?      // mode
    let p: String?   // selected profile label
    let puid: String? // selected profile id
    let cp: Bool?    // pressure capability
    let cd: Bool?    // dimming capability
    let led: Bool?   // LED control
    let bt: Bool?    // brew target
    let btd: Double? // brew target duration
    let bta: Bool?   // volumetric available
    let tw: Double?  // target weight
    let cw: Double?  // current weight
    let bc: Bool?    // bluetooth connected
    let gtd: Double? // grind target duration
    let gtv: Double? // grind target volume
    let gt: Int?     // grind target
    let gact: Bool?  // grind active
    let process: BrewProcess?
}

struct ProfilesListResponse: Decodable {
    let tp: String
    let rid: String?
    let profiles: [Profile]?
    let error: String?
}

struct ProfileResponse: Decodable {
    let tp: String
    let rid: String?
    let profile: Profile?
    let error: String?
}

struct GenericResponse: Decodable {
    let tp: String
    let rid: String?
    let error: String?
}

// MARK: - Outgoing Messages

struct ChangeModeRequest: Encodable {
    let tp = "req:change-mode"
    let mode: Int
}

struct ProfilesListRequest: Encodable {
    let tp = "req:profiles:list"
    let rid: String
}

struct ProfilesSelectRequest: Encodable {
    let tp = "req:profiles:select"
    let rid: String
    let id: String
}

struct ProfilesFavoriteRequest: Encodable {
    let tp: String
    let rid: String
    let id: String
}
