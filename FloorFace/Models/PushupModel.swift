//
//  PushupModel.swift
//  NoseTap
//
//  Data structures that describe pushup activity and configuration.
//

import Foundation

struct PushupDay: Identifiable {
    let id = UUID()
    let dateString: String
    let count: Int
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

