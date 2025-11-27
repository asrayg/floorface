//
//  ContentView.swift
//  FloorFace
//
//  Created by Asray Gopa on 11/26/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        HomeView()
    }
}

#Preview {
    ContentView()
        .environmentObject(PushupViewModel())
        .environmentObject(RecapViewModel())
        .environmentObject(SettingsViewModel())
}
