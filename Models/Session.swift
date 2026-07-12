import Foundation

/// Grand Prix weekend session type.
enum SessionType: String, Codable, CaseIterable {
    case practice1 = "FP1"
    case practice2 = "FP2"
    case practice3 = "FP3"
    case sprintQualifying = "Sprint Qualifying"
    case sprint = "Sprint"
    case qualifying = "Qualifying"
    case race = "Race"

    var displayName: String { rawValue }
    var shortName: String {
        switch self {
        case .practice1: "FP1"
        case .practice2: "FP2"
        case .practice3: "FP3"
        case .sprintQualifying: "SQ"
        case .sprint: "SPR"
        case .qualifying: "Q"
        case .race: "R"
        }
    }
}

/// Session status from timing feed.
enum SessionStatus: String, Codable {
    case upcoming
    case live
    case suspended     // red flag / weather
    case finished
    case cancelled
}

/// Represents a session within a Grand Prix weekend.
struct Session: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let type: SessionType
    let status: SessionStatus
    let startTime: Date
    let endTime: Date?
    let circuitId: String
    let circuitName: String
    let country: String
    let round: Int
    let year: Int

    var isActive: Bool {
        status == .live || status == .suspended
    }

    var formattedStartTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: startTime)
    }

    static let placeholder = Session(
        id: "2026-monaco-r",
        type: .race,
        status: .upcoming,
        startTime: Date().addingTimeInterval(3600),
        endTime: nil,
        circuitId: "monaco",
        circuitName: "Circuit de Monaco",
        country: "Monaco",
        round: 8,
        year: 2026
    )
}
