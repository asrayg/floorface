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
    @State private var shareItems: [Any] = []
    @State private var showShareSheet = false

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

                Section("GIF history") {
                    let gifs = settingsViewModel.availableGIFs()
                    if gifs.isEmpty {
                        Text("No GIFs saved yet.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(gifs, id: \.self) { url in
                            HStack {
                                Text(url.lastPathComponent)
                                Spacer()
                                Button {
                                    shareItems = [url]
                                    showShareSheet = true
                                } label: {
                                    Image(systemName: "square.and.arrow.up")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                sliderValue = Double(settingsViewModel.currentGoal)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: shareItems)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsViewModel())
        .environmentObject(PushupViewModel())
}

