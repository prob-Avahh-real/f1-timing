import Foundation

/// Common date formatters shared across targets.
enum DateFormatterUtility {
    static let sessionTime: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    static let lapTime: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "m:ss.SSS"
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f
    }()

    static let countdown: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEE HH:mm"
        return f
    }()
}

/// Parses a lap time string like "1:23.456" into total seconds.
func lapTimeToSeconds(_ time: String) -> Double {
    let parts = time.split(separator: ":")
    guard parts.count == 2,
          let minutes = Double(parts[0]),
          let seconds = Double(parts[1]) else { return 0 }
    return minutes * 60 + seconds
}

/// Formats a time delta for display.
func formatGap(_ seconds: Double) -> String {
    if abs(seconds) < 0.001 { return "0.000" }
    return String(format: "%+.3f", seconds)
}
