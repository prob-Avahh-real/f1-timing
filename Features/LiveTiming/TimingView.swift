import SwiftUI

struct TimingView: View {
    @State private var viewModel: TimingViewModel

    init(dataSource: TimingDataSource) {
        _viewModel = State(wrappedValue: TimingViewModel(dataSource: dataSource))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerBar
                Divider()
                driverList
            }
            .background(Color.black)
            .navigationBarHidden(true)
            .onAppear {
                viewModel.connect(to: "2026-bahrain-r")
            }
            .onDisappear {
                viewModel.disconnect()
            }
        }
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Bahrain Grand Prix")
                    .font(.headline)
                    .foregroundColor(.white)
                HStack(spacing: 6) {
                    statusBadge
                    Text(viewModel.formattedCurrentLap)
                        .font(.system(.subheadline, design: .monospaced))
                        .foregroundColor(.gray)
                    Spacer()
                    connectionIndicator
                }
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(white: 0.08))
    }

    private var statusBadge: some View {
        Text(viewModel.statusBadge)
            .font(.system(.caption, design: .monospaced, weight: .bold))
            .foregroundColor(.black)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                viewModel.connectionState == .connected
                    ? Color.green
                    : Color.yellow
            )
            .clipShape(Capsule())
    }

    private var connectionIndicator: some View {
        Circle()
            .fill(connectionColor)
            .frame(width: 8, height: 8)
    }

    private var connectionColor: Color {
        switch viewModel.connectionState {
        case .connected: .green
        case .connecting: .yellow
        case .error: .red
        case .disconnected: .gray
        }
    }

    // MARK: - Driver List

    private var driverList: some View {
        ScrollView {
            LazyVStack(spacing: 2) {
                // Column headers
                HStack(spacing: 0) {
                    Text("POS")
                        .frame(width: 36, alignment: .leading)
                    Text("DRIVER")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("LAST")
                        .frame(width: 72, alignment: .trailing)
                    Text("BEST")
                        .frame(width: 72, alignment: .trailing)
                    Text("GAP")
                        .frame(width: 72, alignment: .trailing)
                    Text("S1")
                        .frame(width: 30, alignment: .center)
                    Text("S2")
                        .frame(width: 30, alignment: .center)
                    Text("S3")
                        .frame(width: 30, alignment: .center)
                    Text("TYR")
                        .frame(width: 36, alignment: .center)
                }
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.gray)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)

                ForEach(viewModel.sortedDrivers) { driver in
                    DriverRowView(
                        driver: driver,
                        isExpanded: viewModel.selectedDriverId == driver.driverId
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.selectDriver(
                                viewModel.selectedDriverId == driver.driverId
                                    ? nil
                                    : driver.driverId
                            )
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Driver Row

struct DriverRowView: View {
    let driver: DriverTiming
    let isExpanded: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Main row
            HStack(spacing: 0) {
                positionColumn
                driverColumn
                Text(driver.lastLapTime ?? "--:--.---")
                    .frame(width: 72, alignment: .trailing)
                Text(driver.bestLapTime ?? "--:--.---")
                    .frame(width: 72, alignment: .trailing)
                Text(driver.gapToLeader ?? "--.---")
                    .frame(width: 72, alignment: .trailing)
                sectorColumn(state: driver.sectors[safe: 0] ?? .notAvailable)
                sectorColumn(state: driver.sectors[safe: 1] ?? .notAvailable)
                sectorColumn(state: driver.sectors[safe: 2] ?? .notAvailable)
                tireColumn
            }
            .font(.system(size: 12, design: .monospaced))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(rowBackground)

            // Expanded detail
            if isExpanded {
                DriverDetailView(driver: driver)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private var positionColumn: some View {
        Text(String(driver.position))
            .font(.system(size: 14, weight: .bold, design: .monospaced))
            .frame(width: 36, alignment: .leading)
    }

    private var driverColumn: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(driver.driverCode)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
            Text(statusText)
                .font(.system(size: 9))
                .foregroundColor(statusColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var statusText: String {
        switch driver.status {
        case .onTrack: "ON TRACK"
        case .inPits: "PIT"
        case .outLap: "OUT LAP"
        case .stopped: "STOP"
        case .finished: "FIN"
        case .retired: "OUT"
        }
    }

    private var statusColor: Color {
        switch driver.status {
        case .onTrack: .green
        case .inPits: .orange
        case .outLap: .yellow
        case .stopped: .gray
        case .finished: .white
        case .retired: .red
        }
    }

    private var rowBackground: Color {
        if isExpanded { Color(white: 0.12) }
        else if driver.position % 2 == 0 { Color(white: 0.05) }
        else { .black }
    }

    @ViewBuilder
    private func sectorColumn(state: DriverTiming.SectorState) -> some View {
        Text(state.shortLabel)
            .frame(width: 30, alignment: .center)
            .font(.system(size: 11, weight: .semibold, design: .monospaced))
            .foregroundColor(state.color)
    }

    private var tireColumn: some View {
        Text(tireLabel)
            .frame(width: 36, alignment: .center)
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(tireColor)
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    private var tireLabel: String {
        guard let compound = driver.tireCompound else { return "--" }
        return switch compound {
        case .soft: "S"
        case .medium: "M"
        case .hard: "H"
        case .intermediate: "I"
        case .wet: "W"
        case .unknown: "--"
        }
    }

    private var tireColor: Color {
        guard let compound = driver.tireCompound else { return .gray }
        return switch compound {
        case .soft: .red
        case .medium: .yellow
        case .hard: .white
        case .intermediate: .green
        case .wet: .blue
        case .unknown: .gray
        }
    }
}

// MARK: - Driver Detail (expanded)

struct DriverDetailView: View {
    let driver: DriverTiming

    var body: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                detailRow("Last Lap", driver.lastLapTime ?? "--")
                detailRow("Sector 1", driver.sector1 ?? "--")
                detailRow("Sector 2", driver.sector2 ?? "--")
            }
            VStack(alignment: .leading, spacing: 4) {
                detailRow("Best Lap", driver.bestLapTime ?? "--")
                detailRow("Sector 3", driver.sector3 ?? "--")
                detailRow("Tire Age", "L\(driver.tireAge ?? 0)")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(white: 0.08))
    }

    private func detailRow(_ label: String, _ value: String) -> some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.gray)
                .frame(width: 52, alignment: .leading)
            Text(value)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Extensions

extension DriverTiming.SectorState {
    var shortLabel: String {
        switch self {
        case .none: "▪"
        case .purple: "P"
        case .green: "G"
        case .yellow: "Y"
        case .notAvailable: "·"
        }
    }

    var color: Color {
        switch self {
        case .none: .gray
        case .purple: .purple
        case .green: .green
        case .yellow: .yellow
        case .notAvailable: Color(white: 0.3)
        }
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    TimingView(dataSource: MockTimingDataSource())
        .preferredColorScheme(.dark)
}
