import Foundation

/// Real-time timing snapshot for a single driver during a session.
struct DriverTiming: Identifiable, Codable, Equatable {
    var id: String { driverId }

    let driverId: String
    let driverCode: String
    let position: Int
    let gapToLeader: String?        // e.g. "+1.234"
    let intervalToAhead: String?    // gap to car immediately ahead
    let lastLapTime: String?        // e.g. "1:23.456"
    let bestLapTime: String?
    let sector1: String?
    let sector2: String?
    let sector3: String?
    let sectors: [SectorState]      // per-sector colour coding
    let numberOfLaps: Int
    let status: DriverStatus
    let tireCompound: TireCompound?
    let tireAge: Int?               // laps on current tires

    enum DriverStatus: String, Codable {
        case onTrack = "ON_TRACK"
        case inPits = "IN_PITS"
        case outLap = "OUT_LAP"
        case stopped = "STOPPED"
        case finished = "FINISHED"
        case retired = "RETIRED"
    }

    enum SectorState: String, Codable {
        case none      // grey
        case purple    // session-best sector
        case green     // personal-best sector
        case yellow    // slower than personal best
        case notAvailable
    }

    enum TireCompound: String, Codable {
        case soft, medium, hard, intermediate, wet
        case unknown
    }

    static func empty(driverId: String, driverCode: String, position: Int) -> DriverTiming {
        DriverTiming(
            driverId: driverId,
            driverCode: driverCode,
            position: position,
            gapToLeader: nil,
            intervalToAhead: nil,
            lastLapTime: nil,
            bestLapTime: nil,
            sector1: nil,
            sector2: nil,
            sector3: nil,
            sectors: [.notAvailable, .notAvailable, .notAvailable],
            numberOfLaps: 0,
            status: .stopped,
            tireCompound: nil,
            tireAge: nil
        )
    }
}

/// Complete timing snapshot — the root payload pushed by the timing feed.
struct TimingSnapshot: Codable {
    let sessionId: String
    let timestamp: Date
    let drivers: [DriverTiming]
    let sessionStatus: SessionStatus
    let remainingTime: String?      // countdown for timed sessions
    let currentLap: Int?            // current lap number (null during quali)

    var sortedDrivers: [DriverTiming] {
        drivers.sorted { $0.position < $1.position }
    }
}

/// Individual lap record for lap-by-lap history.
struct LapRecord: Identifiable, Codable {
    var id: String { "\(driverId)-\(lapNumber)" }

    let driverId: String
    let lapNumber: Int
    let lapTime: String
    let sector1: String?
    let sector2: String?
    let sector3: String?
    let tireCompound: DriverTiming.TireCompound?
    let isPersonalBest: Bool
    let isSessionBest: Bool
    let timestamp: Date
}
