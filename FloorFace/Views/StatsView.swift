//
//  StatsView.swift
//  NoseTap
//
//  Displays weekly progress and recent history.
//

import SwiftUI

struct StatsView: View {
    @EnvironmentObject var viewModel: PushupViewModel
    private let dataStore = DataStore.shared
    private let calendar = Calendar.current

    @State private var recentDays: [PushupDay] = []

    var body: some View {
        NavigationStack {
            List {
                Section("Weekly goal") {
                    ProgressView(value: min(Double(viewModel.weeklyProgress), Double(max(viewModel.weeklyGoal, 1))), total: Double(max(viewModel.weeklyGoal, 1))) {
                        Text("Weekly progress")
                    } currentValueLabel: {
                        Text("\(viewModel.weeklyProgress)/\(max(viewModel.weeklyGoal, 1))")
                    }
                    .tint(.green)
                }

                Section("Recent days") {
                    ForEach(recentDays) { day in
                        HStack {
                            Text(day.dateString)
                            Spacer()
                            Text("\(day.count)")
                                .bold()
                        }
                    }
                }
            }
            .navigationTitle("Stats")
            .onAppear(perform: loadRecents)
        }
    }

    private func loadRecents() {
        var days: [PushupDay] = []
        let counts = dataStore.loadDailyCounts()
        for offset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -offset, to: Date()) {
                let formatter = DateFormatter()
                formatter.dateFormat = "E MMM d"
                let keyFormatter = DateFormatter()
                keyFormatter.dateFormat = "yyyy-MM-dd"
                let key = keyFormatter.string(from: date)
                let display = formatter.string(from: date)
                let count = counts[key, default: 0]
                days.append(PushupDay(dateString: display, count: count))
            }
        }
        recentDays = days
    }
}

#Preview {
    StatsView()
        .environmentObject(PushupViewModel())
}

