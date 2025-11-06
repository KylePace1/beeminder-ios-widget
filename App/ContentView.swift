//
//  ContentView.swift
//  BeeminderWidget
//
//  Main app view showing all Beeminder goals
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    @State private var goals: [BeeminderGoal] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingSettings = false

    var body: some View {
        NavigationView {
            ZStack {
                if isLoading {
                    ProgressView("Loading goals...")
                } else if let error = errorMessage {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        Text("Error")
                            .font(.title)
                        Text(error)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        Button("Retry") {
                            Task {
                                await loadGoals()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else if goals.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "target")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        Text("No Goals Found")
                            .font(.title)
                        Text("Configure your Beeminder credentials in settings")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        Button("Open Settings") {
                            showingSettings = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(sortedGoals) { goal in
                            NavigationLink(destination: GoalDetailView(goal: goal)) {
                                GoalRowView(goal: goal)
                            }
                        }
                    }
                    .refreshable {
                        await loadGoals()
                    }
                }
            }
            .navigationTitle("Beeminder Goals")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        Task {
                            await loadGoals()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(isLoading)
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
        .task {
            // Load cached goals first for immediate display
            if let cachedGoals = DataStore.shared.loadGoals() {
                goals = cachedGoals
            }
            // Then fetch fresh data
            await loadGoals()
        }
    }

    // Sort goals by urgency (red first, then orange, blue, green)
    private var sortedGoals: [BeeminderGoal] {
        goals.sorted { goal1, goal2 in
            let priority1 = statusPriority(goal1.status)
            let priority2 = statusPriority(goal2.status)
            if priority1 != priority2 {
                return priority1 < priority2
            }
            return goal1.safetyBufferDays < goal2.safetyBufferDays
        }
    }

    private func statusPriority(_ status: GoalStatus) -> Int {
        switch status {
        case .danger: return 0
        case .warning: return 1
        case .good: return 2
        case .safe: return 3
        case .unknown: return 4
        }
    }

    private func loadGoals() async {
        isLoading = true
        errorMessage = nil

        do {
            let fetchedGoals = try await BeeminderAPI.shared.fetchGoals()
            goals = fetchedGoals
            DataStore.shared.saveGoals(fetchedGoals)

            // Reload widgets with new data
            WidgetCenter.shared.reloadAllTimelines()

            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}

// MARK: - Goal Row View

struct GoalRowView: View {
    let goal: BeeminderGoal

    var body: some View {
        HStack(spacing: 12) {
            Text(goal.statusEmoji)
                .font(.title2)

            VStack(alignment: .leading, spacing: 4) {
                Text(goal.title)
                    .font(.headline)
                Text(goal.limsum)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(goal.safetyBufferDays)d")
                    .font(.headline)
                    .foregroundColor(safetyBufferColor)
                Text("buffer")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var safetyBufferColor: Color {
        switch goal.status {
        case .danger: return .red
        case .warning: return .orange
        case .good: return .blue
        case .safe: return .green
        case .unknown: return .gray
        }
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var username: String = ""
    @State private var authToken: String = ""
    @State private var showingSaved = false

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Username", text: $username)
                        .autocapitalization(.none)
                    SecureField("Auth Token", text: $authToken)
                        .autocapitalization(.none)
                } header: {
                    Text("Beeminder Credentials")
                } footer: {
                    Text("Get your auth token from beeminder.com/api/v1/auth_token.json")
                }

                Section {
                    Button("Save Credentials") {
                        DataStore.shared.saveCredentials(username: username, authToken: authToken)
                        showingSaved = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            dismiss()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(username.isEmpty || authToken.isEmpty)

                    if showingSaved {
                        HStack {
                            Spacer()
                            Label("Saved!", systemImage: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Spacer()
                        }
                    }
                }

                Section {
                    Link("Get Auth Token", destination: URL(string: "https://www.beeminder.com/api/v1/auth_token.json")!)
                    Link("Beeminder API Docs", destination: URL(string: "https://api.beeminder.com/")!)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            if let credentials = DataStore.shared.loadCredentials() {
                username = credentials.username
                authToken = credentials.authToken
            }
        }
    }
}

#Preview {
    ContentView()
}
