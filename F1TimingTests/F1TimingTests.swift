import Testing
import Foundation
@testable import F1Timing

struct F1TimingTests {
    @Test("Driver model creates correctly")
    func testDriverModel() {
        let driver = Driver(
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
        #expect(driver.displayName == "Max Verstappen")
        #expect(driver.shortName == "VER")
        #expect(driver.code == "VER")
    }

    @Test("Timing snapshot sorts drivers by position")
    func testSnapshotSorting() {
        let drivers = [
            DriverTiming(driverId: "PER", driverCode: "PER", position: 2, gapToLeader: nil, intervalToAhead: nil, lastLapTime: nil, bestLapTime: nil, sector1: nil, sector2: nil, sector3: nil, sectors: [], numberOfLaps: 0, status: .onTrack, tireCompound: nil, tireAge: nil),
            DriverTiming(driverId: "VER", driverCode: "VER", position: 1, gapToLeader: nil, intervalToAhead: nil, lastLapTime: nil, bestLapTime: nil, sector1: nil, sector2: nil, sector3: nil, sectors: [], numberOfLaps: 0, status: .onTrack, tireCompound: nil, tireAge: nil),
        ]
        let snapshot = TimingSnapshot(
            sessionId: "test",
            timestamp: Date(),
            drivers: drivers,
            sessionStatus: .live,
            remainingTime: nil,
            currentLap: 1
        )
        #expect(snapshot.sortedDrivers[0].driverId == "VER")
        #expect(snapshot.sortedDrivers[1].driverId == "PER")
    }

    @Test("Session type display names")
    func testSessionTypeNames() {
        #expect(SessionType.race.shortName == "R")
        #expect(SessionType.qualifying.shortName == "Q")
        #expect(SessionType.practice1.shortName == "FP1")
    }

    @Test("DriverTiming empty helper")
    func testDriverTimingEmpty() {
        let empty = DriverTiming.empty(driverId: "TEST", driverCode: "TST", position: 10)
        #expect(empty.driverId == "TEST")
        #expect(empty.position == 10)
        #expect(empty.status == .stopped)
    }
}
