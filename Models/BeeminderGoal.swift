//
//  BeeminderGoal.swift
//  BeeminderWidget
//
//  Data model for Beeminder goals
//

import Foundation

struct BeeminderGoal: Codable, Identifiable {
    let slug: String
    let title: String
    let goalType: String?
    let goalDate: Double
    let losedate: Double
    let curval: Double
    let currate: Double
    let limsum: String
    let roadstatuscolor: String
    let safebuf: Double
    let baremin: String
    let lastday: Double?
    let thumbnail: String?

    var id: String { slug }

    // Computed properties for UI
    var safetyBufferDays: Int {
        Int(floor(safebuf / 86400)) // Convert seconds to days
    }

    var deadlineDate: Date {
        Date(timeIntervalSince1970: losedate)
    }

    var status: GoalStatus {
        switch roadstatuscolor {
        case "green": return .safe
        case "blue": return .good
        case "orange": return .warning
        case "red": return .danger
        default: return .unknown
        }
    }

    var statusEmoji: String {
        switch status {
        case .safe: return "🟢"
        case .good: return "🔵"
        case .warning: return "🟠"
        case .danger: return "🔴"
        case .unknown: return "⚪️"
        }
    }

    enum CodingKeys: String, CodingKey {
        case slug, title, losedate, curval, currate, limsum, safebuf, baremin, lastday, thumbnail
        case goalType = "goal_type"
        case goalDate = "goaldate"
        case roadstatuscolor
    }
}

enum GoalStatus: String, Codable {
    case safe = "green"
    case good = "blue"
    case warning = "orange"
    case danger = "red"
    case unknown
}

// For widget timeline entries
struct GoalEntry: Codable {
    let goal: BeeminderGoal
    let lastUpdated: Date
}
