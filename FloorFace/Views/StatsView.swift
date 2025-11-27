//
//  StatsView.swift
//  NoseTap
//
//  Displays weekly goal progress and trend lines for week, month, and year.
//

import Charts
import SwiftUI

struct StatsView: View {
    @EnvironmentObject var pushupViewModel: PushupViewModel
    @EnvironmentObject var recapViewModel: RecapViewModel
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    goalProgressCard
                    weeklyChart
                    monthlyChart
                    yearlyChart
                }
                .padding()
            }
            .navigationTitle("Stats")
            .onAppear(perform: recapViewModel.refresh)
            .onChange(of: scenePhase) { phase in
                if phase == .active {
                    recapViewModel.refresh()
                }
            }
            .onChange(of: pushupViewModel.todayCount) { _ in
                recapViewModel.refresh()
            }
        }
    }

    private var goalProgressCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Goal")
                .font(.headline)
            ProgressView(
                value: min(Double(pushupViewModel.weeklyProgress), Double(max(pushupViewModel.weeklyGoal, 1))),
                total: Double(max(pushupViewModel.weeklyGoal, 1))
            ) {
                Text("\(pushupViewModel.weeklyProgress) / \(max(pushupViewModel.weeklyGoal, 1))")
            }
            .tint(.green)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }

    private var weeklyChart: some View {
        chartSection(title: "Weekly Trend", subtitle: recapViewModel.weekLabel) {
            Chart(recapViewModel.weeklyPoints) { point in
                LineMark(
                    x: .value("Day", point.label),
                    y: .value("Pushups", point.count)
                )
                PointMark(
                    x: .value("Day", point.label),
                    y: .value("Pushups", point.count)
                )
            }
            .frame(height: 220)
            .chartYScale(domain: 0...max(10, weeklyMax))
        }
    }

    private var monthlyChart: some View {
        chartSection(title: "Monthly Trend", subtitle: recapViewModel.monthLabel) {
            Chart(recapViewModel.monthlyPoints) { point in
                LineMark(
                    x: .value("Day", point.day),
                    y: .value("Pushups", point.count)
                )
                PointMark(
                    x: .value("Day", point.day),
                    y: .value("Pushups", point.count)
                )
            }
            .frame(height: 220)
            .chartYScale(domain: 0...max(10, monthlyMax))
        }
    }

    private var yearlyChart: some View {
        chartSection(title: "Yearly Trend", subtitle: recapViewModel.yearLabel) {
            Chart(recapViewModel.yearlyPoints) { point in
                LineMark(
                    x: .value("Month", point.label),
                    y: .value("Pushups", point.count)
                )
                PointMark(
                    x: .value("Month", point.label),
                    y: .value("Pushups", point.count)
                )
            }
            .frame(height: 220)
            .chartYScale(domain: 0...max(10, yearlyMax))
        }
    }

    private func chartSection<Content: View>(title: String, subtitle: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }

    private var weeklyMax: Int {
        recapViewModel.weeklyPoints.map(\.count).max() ?? 0
    }

    private var monthlyMax: Int {
        recapViewModel.monthlyPoints.map(\.count).max() ?? 0
    }

    private var yearlyMax: Int {
        recapViewModel.yearlyPoints.map(\.count).max() ?? 0
    }
}

#Preview {
    StatsView()
        .environmentObject(PushupViewModel())
        .environmentObject(RecapViewModel())
}
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

