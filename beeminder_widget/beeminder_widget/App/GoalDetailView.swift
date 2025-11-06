//
//  GoalDetailView.swift
//  BeeminderWidget
//
//  Detailed view for a single Beeminder goal
//

import SwiftUI

struct GoalDetailView: View {
    let goal: BeeminderGoal
    @State private var refreshedGoal: BeeminderGoal?
    @State private var isRefreshing = false

    private var displayGoal: BeeminderGoal {
        refreshedGoal ?? goal
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Status Card
                VStack(spacing: 12) {
                    Text(displayGoal.statusEmoji)
                        .font(.system(size: 80))

                    Text(displayGoal.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    HStack(spacing: 20) {
                        VStack {
                            Text("\(displayGoal.safetyBufferDays)")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(safetyBufferColor)
                            Text("Days Safe")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Divider()
                            .frame(height: 60)

                        VStack {
                            Text(String(format: "%.1f", displayGoal.curval))
                                .font(.system(size: 40, weight: .bold))
                            Text("Current Value")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 10)

                // Details
                VStack(alignment: .leading, spacing: 16) {
                    DetailRow(label: "Goal", value: displayGoal.limsum)
                    DetailRow(label: "Deadline", value: formattedDeadline)
                    DetailRow(label: "Rate", value: String(format: "%.2f per day", displayGoal.currate))
                    DetailRow(label: "Bare Minimum", value: displayGoal.baremin)
                    if let goalType = displayGoal.goalType {
                        DetailRow(label: "Type", value: goalType)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 10)

                // Actions
                VStack(spacing: 12) {
                    Button {
                        if let url = URL(string: "https://www.beeminder.com/\(BeeminderAPI.shared.username)/\(displayGoal.slug)") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Label("View on Beeminder.com", systemImage: "safari")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Button {
                        Task {
                            await refreshGoal()
                        }
                    } label: {
                        if isRefreshing {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Label("Refresh Data", systemImage: "arrow.clockwise")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isRefreshing)
                }
                .padding()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var safetyBufferColor: Color {
        switch displayGoal.status {
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
        return formatter.string(from: displayGoal.deadlineDate)
    }

    private func refreshGoal() async {
        isRefreshing = true
        do {
            let updated = try await BeeminderAPI.shared.fetchGoal(slug: goal.slug)
            refreshedGoal = updated
        } catch {
            print("Failed to refresh goal: \(error)")
        }
        isRefreshing = false
    }
}

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    NavigationView {
        GoalDetailView(goal: BeeminderGoal(
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
        ))
    }
}
