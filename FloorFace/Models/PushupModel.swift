//
//  PushupModel.swift
//  NoseTap
//
//  Data structures that describe pushup activity and configuration.
//

import Foundation

struct PushupDay: Identifiable, Codable {
    let id = UUID()
    let dateString: String
    let count: Int
}

struct PushupSession: Identifiable, Codable {
    let id: UUID
    let startedAt: Date
    let count: Int
    let gifURL: URL?

    init(id: UUID = UUID(), startedAt: Date = Date(), count: Int, gifURL: URL?) {
        self.id = id
        self.startedAt = startedAt
        self.count = count
        self.gifURL = gifURL
    }
}

struct WeeklyGoal: Codable {
    var target: Int
    var weekOfYear: Int
    var yearForWeekOfYear: Int

    init(target: Int, referenceDate: Date = Date()) {
        let calendar = Calendar.current
        self.target = target
        self.weekOfYear = calendar.component(.weekOfYear, from: referenceDate)
        self.yearForWeekOfYear = calendar.component(.yearForWeekOfYear, from: referenceDate)
    }
}

enum RecapType: String, Codable {
    case monthly
    case yearly
}

