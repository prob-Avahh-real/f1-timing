import Foundation
import Observation

/// Central view model for the live timing screen.
/// Observes the timing data source and publishes state for SwiftUI.
@MainActor
@Observable
final class TimingViewModel {
    private(set) var snapshot: TimingSnapshot?
    private(set) var connectionState: ConnectionState = .disconnected
    private(set) var selectedDriverId: String?

    /// Sorted driver list — reactive; SwiftUI redraws when this changes.
    var sortedDrivers: [DriverTiming] {
        snapshot?.sortedDrivers ?? []
    }

    var selectedDriver: DriverTiming? {
        guard let id = selectedDriverId else { return nil }
        return snapshot?.drivers.first { $0.driverId == id }
    }

    /// Track map status string for the header.
    var statusBadge: String {
        guard let s = snapshot else { return "No Data" }
        switch s.sessionStatus {
        case .live:     return "LIVE"
        case .suspended: return "RED FLAG"
        case .finished: return "FINISHED"
        default:        return "WAITING"
        }
    }

    var statusColor: String {
        switch snapshot?.sessionStatus {
        case .live:      return "#00FF00"
        case .suspended: return "#FF0000"
        case .finished:  return "#888888"
        default:         return "#AAAAAA"
        }
    }

    var formattedCurrentLap: String {
        guard let lap = snapshot?.currentLap else { return "--" }
        return "L\(lap)"
    }

    private let dataSource: TimingDataSource

    init(dataSource: TimingDataSource) {
        self.dataSource = dataSource

        dataSource.onSnapshot = { [weak self] snap in
            Task { @MainActor in
                self?.snapshot = snap
            }
        }

        dataSource.onConnectionStateChange = { [weak self] state in
            Task { @MainActor in
                self?.connectionState = state
            }
        }
    }

    func connect(to sessionId: String) {
        dataSource.connect(to: sessionId)
    }

    func disconnect() {
        dataSource.disconnect()
    }

    func selectDriver(_ id: String?) {
        selectedDriverId = id
    }
}
