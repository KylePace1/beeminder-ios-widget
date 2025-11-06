//
//  DataStore.swift
//  BeeminderWidget
//
//  Shared data storage between app and widget using App Groups
//

import Foundation

class DataStore {
    static let shared = DataStore()

    // IMPORTANT: This must match the App Group you create in Xcode
    // Format: group.com.yourname.beeminderwidget
    private let appGroupID = "group.com.yourname.beeminderwidget"

    private var userDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    private let goalsKey = "cached_goals"
    private let lastUpdateKey = "last_update"

    // MARK: - Save/Load Goals

    func saveGoals(_ goals: [BeeminderGoal]) {
        guard let userDefaults = userDefaults else {
            print("Failed to access UserDefaults with app group")
            return
        }

        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(goals) {
            userDefaults.set(encoded, forKey: goalsKey)
            userDefaults.set(Date(), forKey: lastUpdateKey)
        }
    }

    func loadGoals() -> [BeeminderGoal]? {
        guard let userDefaults = userDefaults else {
            print("Failed to access UserDefaults with app group")
            return nil
        }

        guard let data = userDefaults.data(forKey: goalsKey) else {
            return nil
        }

        let decoder = JSONDecoder()
        return try? decoder.decode([BeeminderGoal].self, from: data)
    }

    func lastUpdateDate() -> Date? {
        guard let userDefaults = userDefaults else {
            return nil
        }
        return userDefaults.object(forKey: lastUpdateKey) as? Date
    }

    // MARK: - Credentials Storage
    // Note: For production, use Keychain for sensitive data
    // This is simplified for the demo

    func saveCredentials(username: String, authToken: String) {
        guard let userDefaults = userDefaults else { return }
        userDefaults.set(username, forKey: "username")
        userDefaults.set(authToken, forKey: "auth_token")
    }

    func loadCredentials() -> (username: String, authToken: String)? {
        guard let userDefaults = userDefaults else { return nil }
        guard let username = userDefaults.string(forKey: "username"),
              let authToken = userDefaults.string(forKey: "auth_token") else {
            return nil
        }
        return (username, authToken)
    }

    func clearAll() {
        guard let userDefaults = userDefaults else { return }
        userDefaults.removeObject(forKey: goalsKey)
        userDefaults.removeObject(forKey: lastUpdateKey)
        userDefaults.removeObject(forKey: "username")
        userDefaults.removeObject(forKey: "auth_token")
    }
}
