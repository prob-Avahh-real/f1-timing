import Foundation

/// Represents an F1 driver.
struct Driver: Identifiable, Codable, Equatable, Hashable {
    let id: String          // e.g. "VER", "HAM"
    let permanentNumber: Int
    let givenName: String
    let familyName: String
    let code: String        // 3-letter code: "VER"
    let teamId: String
    let teamName: String
    let nationality: String
    let headshotURL: URL?
    let helmetColor: String // hex color for UI accent

    var displayName: String { "\(givenName) \(familyName)" }
    var shortName: String { code }

    static let placeholder = Driver(
        id: "VER",
        permanentNumber: 1,
        givenName: "Max",
        familyName: "Verstappen",
        code: "VER",
        teamId: "red_bull",
        teamName: "Red Bull Racing",
        nationality: "NLD",
        headshotURL: nil,
        helmetColor: "#1E41FF"
    )
}

/// Manufacturer / constructor.
struct Constructor: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let name: String
    let nationality: String
    let color: String

    static let redBull = Constructor(
        id: "red_bull",
        name: "Red Bull Racing",
        nationality: "AUT",
        color: "#3671C6"
    )
}
