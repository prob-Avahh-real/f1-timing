import SwiftUI

struct SessionListView: View {
    @State private var sessions: [Session] = SessionListView.mockSessions
    @State private var selectedFilter: SessionStatus? = nil

    private var filteredSessions: [Session] {
        guard let filter = selectedFilter else { return sessions }
        return sessions.filter { $0.status == filter }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterBar
                Divider()
                if filteredSessions.isEmpty {
                    emptyState
                } else {
                    sessionList
                }
            }
            .background(Color.black)
            .navigationTitle("Sessions")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Filter Bar

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    label: "All",
                    isSelected: selectedFilter == nil,
                    action: { selectedFilter = nil }
                )
                ForEach(SessionStatus.allCases, id: \.rawValue) { status in
                    FilterChip(
                        label: status.rawValue.capitalized,
                        isSelected: selectedFilter == status,
                        action: { selectedFilter = status }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(Color(white: 0.08))
    }

    // MARK: - Session List

    private var sessionList: some View {
        List(filteredSessions) { session in
            SessionCardView(session: session)
                .listRowBackground(Color.black)
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            Text("No sessions match this filter")
                .foregroundColor(.gray)
        }
        .frame(maxHeight: .infinity)
    }

    // MARK: - Mock Data

    static let mockSessions: [Session] = [
        Session(
            id: "2026-bahrain-fp1", type: .practice1, status: .finished,
            startTime: Date().addingTimeInterval(-48 * 3600), endTime: nil,
            circuitId: "bahrain", circuitName: "Bahrain International Circuit",
            country: "Bahrain", round: 1, year: 2026
        ),
        Session(
            id: "2026-bahrain-fp2", type: .practice2, status: .finished,
            startTime: Date().addingTimeInterval(-36 * 3600), endTime: nil,
            circuitId: "bahrain", circuitName: "Bahrain International Circuit",
            country: "Bahrain", round: 1, year: 2026
        ),
        Session(
            id: "2026-bahrain-fp3", type: .practice3, status: .finished,
            startTime: Date().addingTimeInterval(-24 * 3600), endTime: nil,
            circuitId: "bahrain", circuitName: "Bahrain International Circuit",
            country: "Bahrain", round: 1, year: 2026
        ),
        Session(
            id: "2026-bahrain-q", type: .qualifying, status: .finished,
            startTime: Date().addingTimeInterval(-12 * 3600), endTime: nil,
            circuitId: "bahrain", circuitName: "Bahrain International Circuit",
            country: "Bahrain", round: 1, year: 2026
        ),
        Session(
            id: "2026-bahrain-r", type: .race, status: .upcoming,
            startTime: Date().addingTimeInterval(2 * 3600), endTime: nil,
            circuitId: "bahrain", circuitName: "Bahrain International Circuit",
            country: "Bahrain", round: 1, year: 2026
        ),
        Session(
            id: "2026-jeddah-fp1", type: .practice1, status: .upcoming,
            startTime: Date().addingTimeInterval(7 * 86400), endTime: nil,
            circuitId: "jeddah", circuitName: "Jeddah Corniche Circuit",
            country: "Saudi Arabia", round: 2, year: 2026
        ),
    ]
}

extension SessionStatus: CaseIterable {
    public static var allCases: [SessionStatus] {
        [.upcoming, .live, .suspended, .finished, .cancelled]
    }
}

// MARK: - Session Card

struct SessionCardView: View {
    let session: Session

    var body: some View {
        HStack(spacing: 14) {
            // Left accent bar
            RoundedRectangle(cornerRadius: 2)
                .fill(accentColor)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(session.type.displayName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                    statusChip
                }

                Text("\(session.country) — Round \(session.round)")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)

                Text(session.circuitName)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)

                Text(session.formattedStartTime)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(Color(white: 0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var accentColor: Color {
        switch session.type {
        case .race: .red
        case .qualifying, .sprintQualifying: .orange
        case .sprint: .yellow
        case .practice1, .practice2, .practice3: .gray
        }
    }

    private var statusChip: some View {
        Text(session.status.rawValue.capitalized)
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(.black)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(statusChipColor)
            .clipShape(Capsule())
    }

    private var statusChipColor: Color {
        switch session.status {
        case .live: .green
        case .upcoming: .blue
        case .suspended: .red
        case .finished: Color(white: 0.4)
        case .cancelled: .orange
        }
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(isSelected ? .black : .white)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(isSelected ? Color.white : Color(white: 0.2))
                .clipShape(Capsule())
        }
    }
}

#Preview {
    SessionListView()
        .preferredColorScheme(.dark)
}
