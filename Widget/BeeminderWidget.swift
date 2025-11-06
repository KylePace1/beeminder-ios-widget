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
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(goal.statusEmoji)
                    .font(.title)
                Spacer()
                Text("\(goal.safetyBufferDays)d")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(bufferColor)
            }

            Spacer()

            Text(goal.title)
                .font(.headline)
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            Text(goal.limsum)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .padding()
        .background(Color(.systemBackground))
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
        HStack(spacing: 16) {
            VStack(alignment: .center, spacing: 8) {
                Text(goal.statusEmoji)
                    .font(.system(size: 50))
                Text("\(goal.safetyBufferDays)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(bufferColor)
                Text("days safe")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(width: 100)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text(goal.title)
                    .font(.headline)
                    .lineLimit(2)

                Text(goal.limsum)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                Spacer()

                HStack {
                    Label(String(format: "%.1f", goal.curval), systemImage: "chart.line.uptrend.xyaxis")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
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

// MARK: - Large Widget (Multiple Goals)

struct LargeWidgetView: View {
    let goal: BeeminderGoal

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Most Urgent Goal")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(goal.statusEmoji)
                    .font(.title)
            }

            Divider()

            // Main Goal Display
            VStack(alignment: .leading, spacing: 12) {
                Text(goal.title)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(goal.limsum)
                    .font(.body)
                    .foregroundColor(.secondary)

                HStack(spacing: 24) {
                    VStack(alignment: .leading) {
                        Text("Safety Buffer")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(goal.safetyBufferDays) days")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(bufferColor)
                    }

                    VStack(alignment: .leading) {
                        Text("Current Value")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(format: "%.1f", goal.curval))
                            .font(.title3)
                            .fontWeight(.bold)
                    }

                    VStack(alignment: .leading) {
                        Text("Rate")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(format: "%.1f/day", goal.currate))
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                }

                Spacer()

                Text("Deadline: \(formattedDeadline)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
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
