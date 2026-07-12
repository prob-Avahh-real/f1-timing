import WidgetKit
import SwiftUI

/// Provider: determines when to refresh the widget timeline.
struct F1WidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> F1WidgetEntry {
        F1WidgetEntry(
            date: Date(),
            nextSession: .placeholder,
            nextSessionType: "RACE",
            countdownText: "Next: Monaco GP"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (F1WidgetEntry) -> Void) {
        let entry = F1WidgetEntry(
            date: Date(),
            nextSession: .placeholder,
            nextSessionType: "RACE",
            countdownText: "SUN 14:00"
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<F1WidgetEntry>) -> Void) {
        // In a real app, fetch next session from API / UserDefaults
        let entry = F1WidgetEntry(
            date: Date(),
            nextSession: .placeholder,
            nextSessionType: "RACE",
            countdownText: "SUN 14:00"
        )

        // Refresh every 15 minutes
        let nextUpdate = Date().addingTimeInterval(15 * 60)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

/// Data entry for the widget.
struct F1WidgetEntry: TimelineEntry {
    let date: Date
    let nextSession: Session
    let nextSessionType: String
    let countdownText: String
}

// MARK: - Widget Views

struct F1WidgetEntryView: View {
    var entry: F1WidgetProvider.Entry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            mediumWidget
        case .accessoryRectangular:
            accessoryRectangular
        default:
            mediumWidget
        }
    }

    // MARK: Small (current position / next session)

    private var smallWidget: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "flag.checkered")
                    .foregroundColor(.red)
                Text("F1")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.red)
                Spacer()
            }

            Spacer()

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.nextSession.circuitName)
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                    .lineLimit(1)
                Text(entry.countdownText)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
            }

            Text(entry.nextSessionType)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.red)
                .clipShape(Capsule())
        }
        .padding(12)
        .background(Color.black)
    }

    // MARK: Medium (next session details)

    private var mediumWidget: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "flag.checkered")
                        .foregroundColor(.red)
                    Text("Next Session")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.gray)
                }

                Text(entry.nextSession.circuitName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)

                Text("Round \(entry.nextSession.round) — \(entry.nextSession.country)")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)

                Spacer()

                Text(entry.countdownText)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
            }

            Spacer()

            VStack(spacing: 8) {
                Text(entry.nextSessionType)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.red)
                    .clipShape(Capsule())

                Text(entry.nextSession.formattedStartTime)
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
        }
        .padding(14)
        .background(Color.black)
    }

    // MARK: Accessory (watch complications / Lock Screen)

    private var accessoryRectangular: some View {
        HStack {
            Text(entry.countdownText)
                .font(.system(.headline, design: .monospaced))
            Text(entry.nextSession.circuitName)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Widget Definition

struct F1Widget: Widget {
    let kind: String = "F1Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: F1WidgetProvider()) { entry in
            F1WidgetEntryView(entry: entry)
                .containerBackground(.black, for: .widget)
        }
        .configurationDisplayName("F1 Timing")
        .description("Shows the next Grand Prix session and countdown.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}

#Preview(as: .systemSmall) {
    F1Widget()
} timeline: {
    F1WidgetEntry(
        date: Date(),
        nextSession: .placeholder,
        nextSessionType: "RACE",
        countdownText: "SUN 14:00"
    )
}
