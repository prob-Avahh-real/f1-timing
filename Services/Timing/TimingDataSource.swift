import Foundation

/// Protocol that any timing data source must conform to.
/// Makes it easy to swap between mock data, a real F1 feed, or a relay server.
protocol TimingDataSource: Sendable {
    /// Called when a new snapshot arrives.
    var onSnapshot: (@Sendable (TimingSnapshot) -> Void)? { get set }

    /// Called when the connection state changes.
    var onConnectionStateChange: (@Sendable (ConnectionState) -> Void)? { get set }

    /// Start receiving data for a given session.
    func connect(to sessionId: String)

    /// Stop receiving data.
    func disconnect()
}

/// Connection lifecycle states.
enum ConnectionState: Sendable {
    case disconnected
    case connecting
    case connected
    case error(Error)
}

// MARK: - Mock Data Source (for development / demo)

final class MockTimingDataSource: TimingDataSource, @unchecked Sendable {
    var onSnapshot: (@Sendable (TimingSnapshot) -> Void)?
    var onConnectionStateChange: (@Sendable (ConnectionState) -> Void)?

    private var timer: Timer?
    private let mockDrivers: [DriverTiming] = MockTimingDataSource.buildMockGrid()

    func connect(to sessionId: String) {
        onConnectionStateChange?(.connecting)

        // Simulate connection delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self else { return }
            self.onConnectionStateChange?(.connected)

            // Push mock data every 2 seconds
            self.timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
                guard let self else { return }
                let tick = self.buildSnapshot(sessionId: sessionId)
                self.onSnapshot?(tick)
            }

            // Fire immediately
            self.onSnapshot?(self.buildSnapshot(sessionId: sessionId))
        }
    }

    func disconnect() {
        timer?.invalidate()
        timer = nil
        onConnectionStateChange?(.disconnected)
    }

    private func buildSnapshot(sessionId: String) -> TimingSnapshot {
        // Mutate a few positions each tick for visual testing
        var grid = mockDrivers

        // Random position swaps for realism
        if Int.random(in: 0...3) == 0 {
            let target = Int.random(in: 0..<min(3, grid.count))
            let mock = DriverTiming.empty(
                driverId: grid[target].driverId,
                driverCode: grid[target].driverCode,
                position: grid[target].position
            )
            grid[target] = DriverTiming(
                driverId: mock.driverId,
                driverCode: mock.driverCode,
                position: mock.position,
                gapToLeader: mock.gapToLeader,
                intervalToAhead: mock.intervalToAhead,
                lastLapTime: "1:\(Int.random(in: 20...35)).\(Int.random(in: 100...999))",
                bestLapTime: mock.bestLapTime,
                sector1: "\(Int.random(in: 18...22)).\(Int.random(in: 100...999))",
                sector2: "\(Int.random(in: 28...35)).\(Int.random(in: 100...999))",
                sector3: "\(Int.random(in: 30...40)).\(Int.random(in: 100...999))",
                sectors: [
                    SectorState.allCases.filter { $0 != .notAvailable }.randomElement()!,
                    SectorState.allCases.filter { $0 != .notAvailable }.randomElement()!,
                    SectorState.allCases.filter { $0 != .notAvailable }.randomElement()!,
                ],
                numberOfLaps: grid[target].numberOfLaps + 1,
                status: [DriverTiming.DriverStatus.onTrack, .inPits, .onTrack].randomElement()!,
                tireCompound: grid[target].tireCompound,
                tireAge: (grid[target].tireAge ?? 0) + 1
            )
        }

        return TimingSnapshot(
            sessionId: sessionId,
            timestamp: Date(),
            drivers: grid,
            sessionStatus: .live,
            remainingTime: nil,
            currentLap: Int.random(in: 12...50)
        )
    }

    private static func buildMockGrid() -> [DriverTiming] {
        let codes = ["VER", "PER", "HAM", "RUS", "LEC", "SAI", "NOR", "PIA",
                     "ALO", "STR", "GAS", "OCO", "TSU", "LAW", "ALB", "COL",
                     "BOT", "ZHO", "MAG", "HUL"]
        return codes.enumerated().map { idx, code in
            DriverTiming(
                driverId: code,
                driverCode: code,
                position: idx + 1,
                gapToLeader: idx == 0 ? nil : "+\(String(format: "%.3f", Double(idx) * 0.3))",
                intervalToAhead: idx == 0 ? nil : "+0.3",
                lastLapTime: nil,
                bestLapTime: "1:\(28 + idx / 5).\(200 + idx * 30)",
                sector1: nil,
                sector2: nil,
                sector3: nil,
                sectors: [.none, .none, .none],
                numberOfLaps: 5 + idx,
                status: .onTrack,
                tireCompound: [DriverTiming.TireCompound.soft, .medium, .hard].randomElement(),
                tireAge: Int.random(in: 1...20)
            )
        }
    }
}

extension DriverTiming.SectorState: CaseIterable {
    public static var allCases: [DriverTiming.SectorState] {
        [.none, .purple, .green, .yellow, .notAvailable]
    }
}
