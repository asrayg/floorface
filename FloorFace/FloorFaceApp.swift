//
//  FloorFaceApp.swift
//  FloorFace
//
//  Created by Asray Gopa on 11/26/25.
//

import SwiftUI

@main
struct FloorFaceApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
