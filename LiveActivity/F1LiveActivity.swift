import ActivityKit
import SwiftUI
import WidgetKit

/// The UI for the F1 Live Activity as it appears on the Lock Screen and Dynamic Island.
struct F1LiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: F1LiveActivityAttributes.self) { context in
            // Lock Screen display
            lockScreenView(context: context)
                .activityBackgroundTint(Color.black.opacity(0.9))
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            // Dynamic Island
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    expandedLeading(context: context)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    expandedTrailing(context: context)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    expandedBottom(context: context)
                }
            } compactLeading: {
                compactLeadingView(context: context)
            } compactTrailing: {
                compactTrailingView(context: context)
            } minimal: {
                minimalView(context: context)
            }
        }
    }

    // MARK: - Lock Screen

    private func lockScreenView(context: ActivityViewContext<F1LiveActivityAttributes>) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(context.attributes.grandPrixName)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                statusBadge(context.state.sessionStatus)
            }

            HStack(spacing: 12) {
                driverSlot(code: context.state.p1Code, gap: context.state.p1Gap, position: 1)
                driverSlot(code: context.state.p2Code, gap: context.state.p2Gap, position: 2)
                driverSlot(code: context.state.p3Code, gap: context.state.p3Gap, position: 3)
            }

            HStack {
                Text("\(context.state.sessionType) — \(context.state.circuitName)")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                if context.state.totalLaps > 0 {
                    Text("Lap \(context.state.currentLap)/\(context.state.totalLaps)")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
    }

    // MARK: - Dynamic Island Expanded

    private func expandedLeading(context: ActivityViewContext<F1LiveActivityAttributes>) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(context.state.p1Code)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.yellow)
            Text(context.state.p2Code)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.gray)
        }
    }

    private func expandedTrailing(context: ActivityViewContext<F1LiveActivityAttributes>) -> some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(context.state.p1Gap)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.yellow)
            Text(context.state.p2Gap)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.gray)
        }
    }

    private func expandedBottom(context: ActivityViewContext<F1LiveActivityAttributes>) -> some View {
        HStack {
            Text("Lap \(context.state.currentLap)")
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.gray)
            Spacer()
            Text(context.state.p3Code)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.gray)
        }
    }

    // MARK: - Compact / Minimal

    private func compactLeadingView(context: ActivityViewContext<F1LiveActivityAttributes>) -> some View {
        Text(context.state.p1Code)
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .foregroundColor(.yellow)
    }

    private func compactTrailingView(context: ActivityViewContext<F1LiveActivityAttributes>) -> some View {
        Text(context.state.p1Gap)
            .font(.system(size: 10, design: .monospaced))
    }

    private func minimalView(context: ActivityViewContext<F1LiveActivityAttributes>) -> some View {
        Text(context.state.p1Code)
            .font(.system(size: 8, weight: .bold, design: .monospaced))
            .foregroundColor(.yellow)
    }

    // MARK: - Helpers

    private func driverSlot(code: String, gap: String, position: Int) -> some View {
        VStack(spacing: 2) {
            Text("P\(position)")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(position == 1 ? .yellow : .gray)
            Text(code)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            Text(gap)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }

    private func statusBadge(_ status: String) -> some View {
        Text(status)
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .foregroundColor(.black)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(status == "LIVE" ? Color.green : Color.red)
            .clipShape(Capsule())
    }
}
