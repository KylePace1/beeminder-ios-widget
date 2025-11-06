//
//  BeeminderWidget.swift
//  BeeminderWidgetExtension
//
//  Widget extension for displaying Beeminder goals on home screen
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct BeeminderWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> BeeminderWidgetEntry {
        BeeminderWidgetEntry(
            date: Date(),
            goal: placeholderGoal,
            status: .placeholder
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (BeeminderWidgetEntry) -> Void) {
        if context.isPreview {
            let entry = BeeminderWidgetEntry(
                date: Date(),
                goal: placeholderGoal,
                status: .placeholder
            )
            completion(entry)
        } else {
            // Try to load from cache for quick display
            if let cachedGoals = DataStore.shared.loadGoals(),
               let firstGoal = cachedGoals.first {
                let entry = BeeminderWidgetEntry(
                    date: Date(),
                    goal: firstGoal,
                    status: .success
                )
                completion(entry)
            } else {
                completion(placeholder(in: context))
            }
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BeeminderWidgetEntry>) -> Void) {
        Task {
            do {
                // Fetch fresh data from API
                let goals = try await BeeminderAPI.shared.fetchGoals()

                // Save to cache
                DataStore.shared.saveGoals(goals)

                // Find the most urgent goal
                let sortedGoals = goals.sorted { goal1, goal2 in
                    goal1.safetyBufferDays < goal2.safetyBufferDays
                }

                let mostUrgent = sortedGoals.first ?? placeholderGoal

                let entry = BeeminderWidgetEntry(
                    date: Date(),
                    goal: mostUrgent,
                    status: .success
                )

                // Update every 15 minutes
                let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))

                completion(timeline)
            } catch {
                // On error, show error state
                let entry = BeeminderWidgetEntry(
                    date: Date(),
                    goal: placeholderGoal,
                    status: .error(message: "Failed to load goals")
                )

                // Retry in 5 minutes
                let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))

                completion(timeline)
            }
        }
    }

    private var placeholderGoal: BeeminderGoal {
        BeeminderGoal(
            slug: "example",
            title: "Example Goal",
            goalType: "hustler",
            goalDate: Date().timeIntervalSince1970,
            losedate: Date().addingTimeInterval(86400).timeIntervalSince1970,
            curval: 50,
            currate: 1.0,
            limsum: "Do 1 per day",
            roadstatuscolor: "blue",
            safebuf: 172800,
            baremin: "1",
            lastday: Date().timeIntervalSince1970,
            thumbnail: nil
        )
    }
}

// MARK: - Timeline Entry

struct BeeminderWidgetEntry: TimelineEntry {
    let date: Date
    let goal: BeeminderGoal
    let status: WidgetStatus
}

enum WidgetStatus {
    case success
    case placeholder
    case error(message: String)
}

// MARK: - Widget View

struct BeeminderWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: BeeminderWidgetProvider.Entry

    var body: some View {
        switch entry.status {
        case .success:
            successView
        case .placeholder:
            placeholderView
        case .error(let message):
            errorView(message: message)
        }
    }

    @ViewBuilder
    private var successView: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(goal: entry.goal)
        case .systemMedium:
            MediumWidgetView(goal: entry.goal)
        case .systemLarge:
            LargeWidgetView(goal: entry.goal)
        default:
            SmallWidgetView(goal: entry.goal)
        }
    }

    private var placeholderView: some View {
        VStack {
            Image(systemName: "target")
                .font(.largeTitle)
                .foregroundColor(.gray)
            Text("Loading...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title)
                .foregroundColor(.orange)
            Text(message)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// MARK: - Small Widget (Single Goal)

struct SmallWidgetView: View {
    let goal: BeeminderGoal

    var body: some View {
        ZStack {
            // Background with subtle gradient based on status
            LinearGradient(
                colors: [bufferColor.opacity(0.1), bufferColor.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 12) {
                // Status indicator and buffer
                HStack(alignment: .top, spacing: 8) {
                    Text(goal.statusEmoji)
                        .font(.system(size: 32))

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(goal.safetyBufferDays)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(bufferColor)
                        Text("days")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                    }
                }

                Spacer()

                // Goal title and description
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title)
                        .font(.system(size: 16, weight: .semibold))
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .foregroundColor(.primary)

                    Text(goal.limsum)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(16)
        }
    }

    private var bufferColor: Color {
        switch goal.status {
        case .danger: return .red
        case .warning: return .orange
        case .good: return .blue
        case .safe: return .green
        case .unknown: return .gray
        }
    }
}

// MARK: - Medium Widget (Goal with Details)

struct MediumWidgetView: View {
    let goal: BeeminderGoal

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [bufferColor.opacity(0.1), bufferColor.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            HStack(spacing: 20) {
                // Left side: Big visual indicator
                VStack(spacing: 10) {
                    Text(goal.statusEmoji)
                        .font(.system(size: 56))

                    VStack(spacing: 4) {
                        Text("\(goal.safetyBufferDays)")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(bufferColor)
                        Text("DAYS")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                    }
                }
                .frame(width: 110)

                // Right side: Goal details
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(goal.title)
                            .font(.system(size: 18, weight: .bold))
                            .lineLimit(2)
                            .foregroundColor(.primary)

                        Text(goal.limsum)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }

                    Spacer()

                    // Stats row
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Current")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                            Text(String(format: "%.1f", goal.curval))
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Rate")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                            Text(String(format: "%.1f/day", goal.currate))
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(16)
        }
    }

    private var bufferColor: Color {
        switch goal.status {
        case .danger: return .red
        case .warning: return .orange
        case .good: return .blue
        case .safe: return .green
        case .unknown: return .gray
        }
    }
}

// MARK: - Large Widget (Comprehensive Goal View)

struct LargeWidgetView: View {
    let goal: BeeminderGoal

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [bufferColor.opacity(0.12), bufferColor.opacity(0.03)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 20) {
                // Header with emoji and label
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("MOST URGENT")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        Text(goal.title)
                            .font(.system(size: 24, weight: .bold))
                            .lineLimit(2)
                            .foregroundColor(.primary)
                    }

                    Spacer()

                    Text(goal.statusEmoji)
                        .font(.system(size: 50))
                }

                // Description
                Text(goal.limsum)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                Spacer()

                // Stats grid
                VStack(spacing: 16) {
                    HStack(spacing: 20) {
                        StatBox(
                            label: "Safety Buffer",
                            value: "\(goal.safetyBufferDays)",
                            unit: "days",
                            color: bufferColor
                        )

                        StatBox(
                            label: "Current",
                            value: String(format: "%.1f", goal.curval),
                            unit: "",
                            color: .primary
                        )

                        StatBox(
                            label: "Daily Rate",
                            value: String(format: "%.1f", goal.currate),
                            unit: "/day",
                            color: .primary
                        )
                    }

                    // Deadline bar
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 14))
                        Text("Deadline: \(formattedDeadline)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(10)
                }
            }
            .padding(20)
        }
    }

    private var bufferColor: Color {
        switch goal.status {
        case .danger: return .red
        case .warning: return .orange
        case .good: return .blue
        case .safe: return .green
        case .unknown: return .gray
        }
    }

    private var formattedDeadline: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: goal.deadlineDate)
    }
}

// Helper view for stat boxes
struct StatBox: View {
    let label: String
    let value: String
    let unit: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(color)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.black.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Widget Configuration

struct BeeminderWidget: Widget {
    let kind: String = "BeeminderWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BeeminderWidgetProvider()) { entry in
            BeeminderWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Beeminder Goal")
        .description("Track your most urgent Beeminder goal")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Widget Bundle

@main
struct BeeminderWidgetBundle: WidgetBundle {
    var body: some Widget {
        BeeminderWidget()
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    BeeminderWidget()
} timeline: {
    BeeminderWidgetEntry(
        date: .now,
        goal: BeeminderGoal(
            slug: "example",
            title: "Write Daily",
            goalType: "hustler",
            goalDate: Date().timeIntervalSince1970,
            losedate: Date().addingTimeInterval(86400).timeIntervalSince1970,
            curval: 500,
            currate: 1.0,
            limsum: "Write 1 page per day",
            roadstatuscolor: "orange",
            safebuf: 43200,
            baremin: "1",
            lastday: Date().timeIntervalSince1970,
            thumbnail: nil
        ),
        status: .success
    )
}
