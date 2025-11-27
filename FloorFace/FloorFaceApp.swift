//
//  FloorFaceApp.swift
//  FloorFace
//
//  Created by Asray Gopa on 11/26/25.
//

import SwiftUI

@main
struct NoseTapApp: App {
    @StateObject private var pushupViewModel = PushupViewModel()
    @StateObject private var recapViewModel = RecapViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()
    @StateObject private var appStateViewModel = AppStateViewModel()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(pushupViewModel)
                .environmentObject(recapViewModel)
                .environmentObject(settingsViewModel)
                .environmentObject(appStateViewModel)
        }
    }
}
