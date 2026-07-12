import SwiftUI

/// Shared color palette for F1 Timing.
enum F1Colors {
    static let background = Color.black
    static let surface = Color(white: 0.08)
    static let surfaceAlt = Color(white: 0.05)
    static let textPrimary = Color.white
    static let textSecondary = Color.gray
    static let brandRed = Color.red
    static let brandBlack = Color.black

    // Sector time colors
    static let purple = Color.purple
    static let green = Color.green
    static let yellow = Color.yellow
    static let grey = Color.gray

    // Tire compound colors
    static let tireSoft = Color.red
    static let tireMedium = Color.yellow
    static let tireHard = Color.white
    static let tireIntermediate = Color.green
    static let tireWet = Color.blue

    // Status
    static let statusLive = Color.green
    static let statusSuspended = Color.red
    static let statusFinished = Color(white: 0.5)
}
