//
//  BeeminderUser.swift
//  BeeminderWidget
//
//  Data model for Beeminder user
//

import Foundation

struct BeeminderUser: Codable {
    let username: String
    let timezone: String
    let updatedAt: Double?
    let goals: [String]?

    enum CodingKeys: String, CodingKey {
        case username, timezone, goals
        case updatedAt = "updated_at"
    }
}
