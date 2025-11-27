//
//  PushupViewModel.swift
//  FloorFace
//
//  Handles live pushup capture, persistence, and media creation.
//

import Combine
import Foundation

@MainActor
final class PushupViewModel: ObservableObject {
    @Published var todayCount: Int = 0
    @Published var sessionCount: Int = 0
    @Published var isSessionActive = false
    @Published var weeklyGoal: Int = 0
    @Published var weeklyProgress: Int = 0
    @Published var errorMessage: String?

    private let dataStore: DataStore
    private let calendar: Calendar
    private let dayFormatter: DateFormatter

    private var lastTouchTimestamp: TimeInterval = 0

    init(
        dataStore: DataStore = .shared,
        calendar: Calendar = .current
    ) {
        self.dataStore = dataStore
        self.calendar = calendar

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.dayFormatter = formatter

        bootstrap()
    }

    private func bootstrap() {
        let counts = dataStore.loadDailyCounts()
        let key = dayFormatter.string(from: Date())
        todayCount = counts[key, default: 0]
        let storedGoal = dataStore.weeklyGoal()
        if storedGoal == 0 {
            dataStore.updateWeeklyGoal(100)
            weeklyGoal = 100
        } else {
            weeklyGoal = storedGoal
        }
        weeklyProgress = dataStore.totalForWeek(containing: Date())
    }

    func handleTouch() {
        guard isSessionActive else { return }
        let now = Date().timeIntervalSince1970
        guard now - lastTouchTimestamp > 0.3 else { return }
        lastTouchTimestamp = now
        sessionCount += 1
        todayCount = dataStore.incrementDailyCount(for: Date(), by: 1)
        weeklyProgress = dataStore.totalForWeek(containing: Date())
        refreshStreak()
    }

    func handleDecrement() {
        guard todayCount > 0 else { return }
        todayCount = dataStore.decrementDailyCount(for: Date(), by: 1)
        sessionCount = max(sessionCount - 1, 0)
        weeklyProgress = dataStore.totalForWeek(containing: Date())
        refreshStreak()
    }

    func startSession() {
        guard !isSessionActive else { return }
        isSessionActive = true
        sessionCount = 0
    }

    func endSession() {
        guard isSessionActive else { return }
        isSessionActive = false
        // Add an extra pushup when ending the session
        if sessionCount > 0 {
            todayCount = dataStore.incrementDailyCount(for: Date(), by: 1)
            weeklyProgress = dataStore.totalForWeek(containing: Date())
            refreshStreak()
        }
        sessionCount = 0
    }

    func refreshStoredProgress() {
        let counts = dataStore.loadDailyCounts()
        let key = dayFormatter.string(from: Date())
        todayCount = counts[key, default: 0]
        weeklyProgress = dataStore.totalForWeek(containing: Date())
    }

    // MARK: - Weekly Goal Helpers

    func updateWeeklyGoal(to value: Int) {
        weeklyGoal = value
        dataStore.updateWeeklyGoal(value)
    }

    // MARK: - Streaks

    private func refreshStreak() {
        let counts = dataStore.loadDailyCounts()
        var streak = 0
        var cursor = Date()
        while true {
            let key = dayFormatter.string(from: cursor)
            guard let value = counts[key], value > 0 else { break }
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }
        dataStore.updateStreak(streak)
    }
}

