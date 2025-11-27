//
//  PushupViewModel.swift
//  NoseTap
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
    private let notificationService: NotificationService
    private let calendar: Calendar
    private let dayFormatter: DateFormatter

    private var lastTouchTimestamp: TimeInterval = 0

    init(
        dataStore: DataStore = .shared,
        notificationService: NotificationService = .shared,
        calendar: Calendar = .current
    ) {
        self.dataStore = dataStore
        self.notificationService = notificationService
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
        notificationService.requestAuthorization()
    }

    func handleTouch() {
        let now = Date().timeIntervalSince1970
        guard now - lastTouchTimestamp > 0.3 else { return }
        lastTouchTimestamp = now
        if !isSessionActive {
            startSession()
        }
        sessionCount += 1
        todayCount = dataStore.incrementDailyCount(for: Date(), by: 1)
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
        sessionCount = 0
    }

    private func recordClip() {
        isRecordingClip = true
        videoRecorder.recordClip { [weak self] result in
            Task { @MainActor in
                guard let self else { return }
                self.isRecordingClip = false
                switch result {
                case .success(let url):
                    self.pendingVideoURL = url
                    self.makeGIFIfPossible()
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func makeGIFIfPossible() {
        guard let videoURL = pendingVideoURL else { return }
        let destination = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("gif")

        gifService.createGIFFromVideo(videoURL: videoURL, destinationURL: destination) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let gifURL):
                do {
                    let data = try Data(contentsOf: gifURL)
                    let savedURL = try self.dataStore.saveGIF(data: data, for: Date())
                    DispatchQueue.main.async {
                        self.lastGIFURL = savedURL
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.errorMessage = error.localizedDescription
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
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

