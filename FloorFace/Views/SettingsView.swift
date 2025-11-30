import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var pushupViewModel: PushupViewModel

    @State private var sliderValue: Double = 200
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(spacing: 16) {
                    Image("FloorFace")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(Color(.systemGroupedBackground))
                
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
                    .disabled(Int(sliderValue) == settingsViewModel.currentGoal)
                    if Int(sliderValue) == settingsViewModel.currentGoal {
                        Text("Current goal already set")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Notifications") {
                    Picker("Daily reminder time", selection: Binding(
                        get: { settingsViewModel.notificationHour },
                        set: { settingsViewModel.setNotificationHour($0) }
                    )) {
                        ForEach(0..<24) { hour in
                            Text(formatHour(hour)).tag(hour)
                        }
                    }
                }

                Section("About FloorFace") {
                    Text("FloorFace keeps you honest on the floor. It was built and is maintained by Asray Gopa to make pushup tracking simple, offline, and fun.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 4)
                }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                sliderValue = Double(settingsViewModel.currentGoal)
            }
        }
    }
    
    private func formatHour(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let date = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) ?? Date()
        return formatter.string(from: date)
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsViewModel())
        .environmentObject(PushupViewModel())
}

