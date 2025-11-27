//
//  NotificationService.swift
//  NoseTap
//
//  Handles local notification scheduling for daily reminders.
//

import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()
    private let center = UNUserNotificationCenter.current()

    private init() {}

    func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            if granted {
                self.scheduleDailyReminder()
            }
        }
    }

    func scheduleDailyReminder(at hour: Int = 18) {
        center.removePendingNotificationRequests(withIdentifiers: ["dailyPushupReminder"])

        var dateComponents = DateComponents()
        dateComponents.hour = hour

        let content = UNMutableNotificationContent()
        content.title = "Time for today’s pushups!"
        content.body = "NoseTap is ready."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyPushupReminder", content: content, trigger: trigger)
        center.add(request)
    }
}

