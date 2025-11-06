//
//  BeeminderAPI.swift
//  BeeminderWidget
//
//  Service layer for Beeminder API interactions
//

import Foundation

class BeeminderAPI {
    static let shared = BeeminderAPI()

    private let baseURL = "https://www.beeminder.com/api/v1"
    let username: String  // Made public so GoalDetailView can access it
    private let authToken: String

    // MARK: - Configuration
    init(username: String = "kyle", authToken: String = "9BErv46PRvNEbXPCMZDT") {
        self.username = username
        self.authToken = authToken
    }

    // MARK: - API Methods

    /// Fetch all goals for the authenticated user
    func fetchGoals() async throws -> [BeeminderGoal] {
        let endpoint = "\(baseURL)/users/\(username)/goals.json"
        guard var components = URLComponents(string: endpoint) else {
            throw BeeminderAPIError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "auth_token", value: authToken)
        ]

        guard let url = components.url else {
            throw BeeminderAPIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw BeeminderAPIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw BeeminderAPIError.httpError(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        let goals = try decoder.decode([BeeminderGoal].self, from: data)
        return goals
    }

    /// Fetch a specific goal
    func fetchGoal(slug: String) async throws -> BeeminderGoal {
        let endpoint = "\(baseURL)/users/\(username)/goals/\(slug).json"
        guard var components = URLComponents(string: endpoint) else {
            throw BeeminderAPIError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "auth_token", value: authToken)
        ]

        guard let url = components.url else {
            throw BeeminderAPIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw BeeminderAPIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw BeeminderAPIError.httpError(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        let goal = try decoder.decode(BeeminderGoal.self, from: data)
        return goal
    }

    /// Add a datapoint to a goal
    func addDatapoint(goalSlug: String, value: Double, comment: String? = nil) async throws {
        let endpoint = "\(baseURL)/users/\(username)/goals/\(goalSlug)/datapoints.json"
        guard var components = URLComponents(string: endpoint) else {
            throw BeeminderAPIError.invalidURL
        }

        var queryItems = [
            URLQueryItem(name: "auth_token", value: authToken),
            URLQueryItem(name: "value", value: String(value))
        ]

        if let comment = comment {
            queryItems.append(URLQueryItem(name: "comment", value: comment))
        }

        components.queryItems = queryItems

        guard let url = components.url else {
            throw BeeminderAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw BeeminderAPIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw BeeminderAPIError.httpError(statusCode: httpResponse.statusCode)
        }
    }
}

// MARK: - Error Handling

enum BeeminderAPIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}
