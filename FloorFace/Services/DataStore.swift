//
//  DataStore.swift
//  FloorFace
//
//  Centralized persistence helper for UserDefaults and local files.
//

import Foundation
final class DataStore {
    static let shared = DataStore()

    private enum Key {
        static let dailyPushups = "dailyPushups"
        static let weeklyGoal = "weeklyGoal"
        static let lastGoalPrompt = "lastGoalPrompt"
        static let streakCount = "streakCount"
        static let hasPromptedForNotifications = "hasPromptedForNotifications"
        static let notificationsEnabled = "notificationsEnabled"
    }

    private let defaults: UserDefaults
    private let calendar: Calendar
    private let isoFormatter: DateFormatter

    private init(defaults: UserDefaults = .standard, calendar: Calendar = .current) {
        self.defaults = defaults
        self.calendar = calendar

        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.dateFormat = "yyyy-MM-dd"
        self.isoFormatter = formatter

    }

    // MARK: - Daily counts

    func loadDailyCounts() -> [String: Int] {
        defaults.dictionary(forKey: Key.dailyPushups) as? [String: Int] ?? [:]
    }

    func saveDailyCounts(_ counts: [String: Int]) {
        defaults.set(counts, forKey: Key.dailyPushups)
    }

    @discardableResult
    func incrementDailyCount(for date: Date, by amount: Int) -> Int {
        let key = isoFormatter.string(from: date)
        var counts = loadDailyCounts()
        counts[key, default: 0] += amount
        saveDailyCounts(counts)
        return counts[key, default: 0]
    }

    @discardableResult
    func decrementDailyCount(for date: Date, by amount: Int) -> Int {
        let key = isoFormatter.string(from: date)
        var counts = loadDailyCounts()
        let current = counts[key, default: 0]
        counts[key] = max(current - amount, 0)
        saveDailyCounts(counts)
        return counts[key, default: 0]
    }

    func totalForWeek(containing date: Date) -> Int {
        let counts = loadDailyCounts()
        let start = startOfWeek(for: date)
        var total = 0
        for offset in 0..<7 {
            if let dayDate = calendar.date(byAdding: .day, value: offset, to: start) {
                let key = isoFormatter.string(from: dayDate)
                total += counts[key, default: 0]
            }
        }
        return total
    }

    func totalForMonth(containing date: Date) -> (total: Int, bestDay: (Date, Int)?) {
        let counts = loadDailyCounts()
        guard let range = calendar.range(of: .day, in: .month, for: date) else { return (0, nil) }
        let first = startOfMonth(for: date)
        var total = 0
        var best: (Date, Int)?
        for day in range {
            if let dayDate = calendar.date(byAdding: .day, value: day - 1, to: first) {
                let key = isoFormatter.string(from: dayDate)
                let count = counts[key, default: 0]
                total += count
                if let currentBest = best {
                    if count > currentBest.1 {
                        best = (dayDate, count)
                    }
                } else if count > 0 {
                    best = (dayDate, count)
                }
            }
        }
        return (total, best)
    }

    func totalForYear(_ year: Int) -> (total: Int, bestMonth: (Int, Int)?) {
        let counts = loadDailyCounts()
        var total = 0
        var best: (Int, Int)?
        for month in 1...12 {
            var monthTotal = 0
            var comps = DateComponents()
            comps.year = year
            comps.month = month
            comps.day = 1
            guard let monthDate = calendar.date(from: comps),
                  let range = calendar.range(of: .day, in: .month, for: monthDate)
            else { continue }

            for day in range {
                comps.day = day
                if let dayDate = calendar.date(from: comps) {
                    let key = isoFormatter.string(from: dayDate)
                    monthTotal += counts[key, default: 0]
                }
            }
            total += monthTotal
            if let currentBest = best {
                if monthTotal > currentBest.1 {
                    best = (month, monthTotal)
                }
            } else if monthTotal > 0 {
                best = (month, monthTotal)
            }
        }

        if total == 0 {
            return (0, nil)
        }
        return (total, best)
    }

    // MARK: - Weekly goal

    func weeklyGoal() -> Int {
        defaults.integer(forKey: Key.weeklyGoal)
    }

    func updateWeeklyGoal(_ value: Int) {
        defaults.set(value, forKey: Key.weeklyGoal)
    }

    func lastGoalPromptDate() -> Date? {
        defaults.object(forKey: Key.lastGoalPrompt) as? Date
    }

    func setLastGoalPrompt(_ date: Date) {
        defaults.set(date, forKey: Key.lastGoalPrompt)
    }

    func streakCount() -> Int {
        defaults.integer(forKey: Key.streakCount)
    }

    func updateStreak(_ value: Int) {
        defaults.set(value, forKey: Key.streakCount)
    }

    func hasPromptedForNotifications() -> Bool {
        defaults.bool(forKey: Key.hasPromptedForNotifications)
    }

    func setPromptedForNotifications(_ value: Bool) {
        defaults.set(value, forKey: Key.hasPromptedForNotifications)
    }

    func notificationsEnabled() -> Bool {
        defaults.bool(forKey: Key.notificationsEnabled)
    }

    func setNotificationsEnabled(_ value: Bool) {
        defaults.set(value, forKey: Key.notificationsEnabled)
    }

    // MARK: - Chart helpers

    func weeklySeries(for date: Date = Date()) -> [(label: String, count: Int)] {
        let counts = loadDailyCounts()
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.dateFormat = "EEE"
        let start = startOfWeek(for: date)
        var result: [(String, Int)] = []
        for offset in 0..<7 {
            guard let dayDate = calendar.date(byAdding: .day, value: offset, to: start) else { continue }
            let key = isoFormatter.string(from: dayDate)
            let label = formatter.string(from: dayDate)
            result.append((label, counts[key, default: 0]))
        }
        return result
    }

    func dailySeries(forMonthContaining date: Date) -> [(day: Int, count: Int)] {
        let counts = loadDailyCounts()
        guard let range = calendar.range(of: .day, in: .month, for: date) else { return [] }
        let first = startOfMonth(for: date)
        return range.compactMap { day -> (Int, Int)? in
            guard let dayDate = calendar.date(byAdding: .day, value: day - 1, to: first) else { return nil }
            let key = isoFormatter.string(from: dayDate)
            return (day, counts[key, default: 0])
        }
    }

    func monthlySeries(for year: Int) -> [(month: Int, count: Int)] {
        let counts = loadDailyCounts()
        var result: [(Int, Int)] = []
        for month in 1...12 {
            var comps = DateComponents()
            comps.year = year
            comps.month = month
            comps.day = 1
            guard let monthDate = calendar.date(from: comps),
                  let range = calendar.range(of: .day, in: .month, for: monthDate) else { continue }
            var total = 0
            for day in range {
                comps.day = day
                if let dayDate = calendar.date(from: comps) {
                    let key = isoFormatter.string(from: dayDate)
                    total += counts[key, default: 0]
                }
            }
            result.append((month, total))
        }
        return result
    }

    // MARK: - Helpers

    private func startOfWeek(for date: Date) -> Date {
        calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) ?? date
    }

    private func startOfMonth(for date: Date) -> Date {
        let comps = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: comps) ?? date
    }
}

