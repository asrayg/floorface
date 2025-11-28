import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()
    private let center = UNUserNotificationCenter.current()
    private let dataStore: DataStore

    private init(dataStore: DataStore = .shared) {
        self.dataStore = dataStore
    }

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                self.dataStore.setPromptedForNotifications(true)
                self.dataStore.setNotificationsEnabled(granted)
                if granted {
                    self.scheduleDailyReminder()
                    self.scheduleWeeklyGoalReminder()
                } else {
                    self.center.removeAllPendingNotificationRequests()
                }
                completion(granted)
            }
        }
    }

    func scheduleDailyReminder(at hour: Int = 18) {
        guard dataStore.notificationsEnabled() else { return }
        center.removePendingNotificationRequests(withIdentifiers: ["dailyPushupReminder"])

        var dateComponents = DateComponents()
        dateComponents.hour = hour

        let content = UNMutableNotificationContent()
        content.title = "Time for today’s pushups!"
        content.body = "FloorFace is ready."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyPushupReminder", content: content, trigger: trigger)
        center.add(request)
    }

    func scheduleWeeklyGoalReminder() {
        guard dataStore.notificationsEnabled() else { return }
        center.removePendingNotificationRequests(withIdentifiers: ["weeklyGoalReminder"])

        var comps = DateComponents()
        comps.weekday = 1
        comps.hour = 9

        let content = UNMutableNotificationContent()
        content.title = "Set next week’s goal"
        content.body = "Sunday check-in: ready to increase your pushup target?"
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let request = UNNotificationRequest(identifier: "weeklyGoalReminder", content: content, trigger: trigger)
        center.add(request)
    }
}

