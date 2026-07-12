import ActivityKit
import Foundation

/// Describes the data that the Live Activity displays and receives via push.
struct F1LiveActivityAttributes: ActivityAttributes {
    /// Static content — set when the activity starts, not updated.
    public struct ContentState: Codable, Hashable {
        /// Top 3 drivers with current gap to leader.
        var p1Code: String
        var p1Gap: String        // "Leader" or "-"
        var p2Code: String
        var p2Gap: String
        var p3Code: String
        var p3Gap: String

        /// Session context.
        var sessionType: String  // "RACE" / "Q" / "FP1" etc.
        var circuitName: String
        var currentLap: Int
        var totalLaps: Int       // or 0 for timed sessions
        var sessionStatus: String // "LIVE", "RED FLAG", "FINISHED"
    }

    /// Immutable attributes set at launch.
    var grandPrixName: String
    var startTime: Date
}

// MARK: - Live Activity Manager

/// Manages the lifecycle of the F1 Live Activity.
/// Call from the main app when a session goes live / finishes.
@MainActor
final class F1LiveActivityManager {
    static let shared = F1LiveActivityManager()
    private var currentActivity: Activity<F1LiveActivityAttributes>?

    private init() {}

    /// Start the Live Activity for a session.
    func start(
        grandPrixName: String,
        startTime: Date,
        initial: F1LiveActivityAttributes.ContentState
    ) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = F1LiveActivityAttributes(
            grandPrixName: grandPrixName,
            startTime: startTime
        )

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: initial, staleDate: nil)
            )
            currentActivity = activity
        } catch {
            print("Live Activity failed to start: \(error)")
        }
    }

    /// Push updated timing data.
    func update(_ state: F1LiveActivityAttributes.ContentState) {
        Task {
            await currentActivity?.update(
                ActivityContent(state: state, staleDate: Date().addingTimeInterval(10))
            )
        }
    }

    /// End the Live Activity.
    func end() {
        Task {
            await currentActivity?.end(
                ActivityContent(
                    state: F1LiveActivityAttributes.ContentState(
                        p1Code: "--", p1Gap: "--",
                        p2Code: "--", p2Gap: "--",
                        p3Code: "--", p3Gap: "--",
                        sessionType: "--",
                        circuitName: "--",
                        currentLap: 0, totalLaps: 0,
                        sessionStatus: "FINISHED"
                    ),
                    staleDate: Date()
                ),
                dismissalPolicy: .immediate
            )
            currentActivity = nil
        }
    }
}
