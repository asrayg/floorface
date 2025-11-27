//
//  SettingsView.swift
//  NoseTap
//
//  Houses goal controls, notifications, and sharing.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var pushupViewModel: PushupViewModel

    @State private var sliderValue: Double = 100
    var body: some View {
        NavigationStack {
            Form {
                Section("Weekly goal") {
                    Slider(value: $sliderValue, in: 20...2000, step: 10) {
                        Text("Weekly Goal")
                    }
                    Text("\(Int(sliderValue)) pushups")
                        .font(.headline)
                    Button("Update goal") {
                        let goal = Int(sliderValue)
                        settingsViewModel.setWeeklyGoal(goal)
                        pushupViewModel.updateWeeklyGoal(to: goal)
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                sliderValue = Double(settingsViewModel.currentGoal)
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsViewModel())
        .environmentObject(PushupViewModel())
}

