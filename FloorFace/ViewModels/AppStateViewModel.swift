//
//  AppStateViewModel.swift
//  NoseTap
//
//  Tracks app-wide prompts such as notification permissions.
//

import Foundation

@MainActor
final class AppStateViewModel: ObservableObject {
    @Published var showNotificationPrompt: Bool

    private let dataStore: DataStore

    init(dataStore: DataStore = .shared) {
        self.dataStore = dataStore
        self.showNotificationPrompt = !dataStore.hasPromptedForNotifications()
    }

    func dismissNotificationPrompt() {
        dataStore.setPromptedForNotifications(true)
        showNotificationPrompt = false
    }
}

