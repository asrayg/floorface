//
//  HomeView.swift
//  NoseTap
//
//  Root tab layout for NoseTap.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var pushupViewModel: PushupViewModel
    @EnvironmentObject var recapViewModel: RecapViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel

    @State private var goalInput: Double = 100

    var body: some View {
        TabView {
            PushupCaptureView()
                .tabItem {
                    Label("Capture", systemImage: "hand.tap")
                }

            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }

            RecapView()
                .tabItem {
                    Label("Recaps", systemImage: "sparkles")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .onAppear {
            recapViewModel.refresh()
            settingsViewModel.evaluateGoalPrompt()
            goalInput = Double(settingsViewModel.currentGoal)
        }
        .sheet(isPresented: $settingsViewModel.showGoalPrompt) {
            WeeklyGoalPromptView(
                currentGoal: $goalInput,
                suggestedGoal: settingsViewModel.suggestedGoal,
                onConfirm: { goal in
                    settingsViewModel.setWeeklyGoal(Int(goal))
                    pushupViewModel.updateWeeklyGoal(to: Int(goal))
                }
            )
            .presentationDetents([.medium])
        }
        .onChange(of: settingsViewModel.showGoalPrompt) { show in
            if show {
                goalInput = Double(settingsViewModel.currentGoal)
            }
        }
    }
}

private struct WeeklyGoalPromptView: View {
    @Binding var currentGoal: Double
    let suggestedGoal: Int
    let onConfirm: (Double) -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("New Weekly Goal")
                .font(.title2)
                .bold()

            Text("How many pushups do you want to do this week?")
                .multilineTextAlignment(.center)

            Slider(value: $currentGoal, in: 20...2000, step: 10) {
                Text("Goal")
            }

            Text("\(Int(currentGoal)) pushups")
                .font(.headline)

            if suggestedGoal > 0 {
                Text("Suggested increase: \(suggestedGoal)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Button {
                onConfirm(currentGoal)
            } label: {
                Text("Save Goal")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
            }
        }
        .padding()
    }
}

#Preview {
    HomeView()
        .environmentObject(PushupViewModel())
        .environmentObject(RecapViewModel())
        .environmentObject(SettingsViewModel())
}

