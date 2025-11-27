//
//  SettingsViewModel.swift
//  NoseTap
//
//  Manages weekly goals, prompts, and sharing helpers.
//

import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var currentGoal: Int
    @Published var suggestedGoal: Int
    @Published var showGoalPrompt = false

    private let dataStore: DataStore
    private let calendar: Calendar

    init(dataStore: DataStore = .shared, calendar: Calendar = .current) {
        self.dataStore = dataStore
        self.calendar = calendar
        let storedGoal = dataStore.weeklyGoal()
        if storedGoal == 0 {
            dataStore.updateWeeklyGoal(100)
        }
        let initialGoal = storedGoal > 0 ? storedGoal : 100
        self.currentGoal = initialGoal
        self.suggestedGoal = Self.defaultSuggestedGoal(from: initialGoal)
        evaluateGoalPrompt()
    }

    func evaluateGoalPrompt(date: Date = Date()) {
        if shouldPrompt(for: date) {
            showGoalPrompt = true
        }
    }

    func setWeeklyGoal(_ goal: Int, for date: Date = Date()) {
        currentGoal = goal
        dataStore.updateWeeklyGoal(goal)
        dataStore.setLastGoalPrompt(date)
        suggestedGoal = Self.defaultSuggestedGoal(from: goal)
        showGoalPrompt = false
    }

    func updateSuggestedGoal(using currentWeekTotal: Int) {
        let increase = max(Int(Double(currentWeekTotal) * 0.1), 5)
        suggestedGoal = currentGoal + increase
    }

    func shouldPrompt(for date: Date) -> Bool {
        let weekday = calendar.component(.weekday, from: date)
        guard weekday == 1 else { return false } // Sunday
        guard let lastPrompt = dataStore.lastGoalPromptDate() else { return true }
        return calendar.compare(lastPrompt, to: date, toGranularity: .weekOfYear) != .orderedSame
    }

    private static func defaultSuggestedGoal(from goal: Int) -> Int {
        max(Int(Double(goal) * 1.1), goal + 5)
    }
}

