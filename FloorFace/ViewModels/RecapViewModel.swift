//
//  RecapViewModel.swift
//  NoseTap
//
//  Provides data points for weekly, monthly, and yearly charts.
//

import Foundation

struct WeeklyLinePoint: Identifiable {
    let id = UUID()
    let label: String
    let count: Int
}

struct DailyLinePoint: Identifiable {
    let id = UUID()
    let day: Int
    let count: Int
}

struct MonthlyLinePoint: Identifiable {
    let id = UUID()
    let month: Int
    let label: String
    let count: Int
}

@MainActor
final class RecapViewModel: ObservableObject {
    @Published var weeklyPoints: [WeeklyLinePoint] = []
    @Published var monthlyPoints: [DailyLinePoint] = []
    @Published var yearlyPoints: [MonthlyLinePoint] = []
    @Published var weekLabel: String = ""
    @Published var monthLabel: String = ""
    @Published var yearLabel: String = ""

    private let dataStore: DataStore
    private let calendar: Calendar

    init(dataStore: DataStore = .shared, calendar: Calendar = .current) {
        self.dataStore = dataStore
        self.calendar = calendar
        refresh()
    }

    func refresh(referenceDate: Date = Date()) {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.dateFormat = "MMM d"

        let weekData = dataStore.weeklySeries(for: referenceDate)
        weeklyPoints = weekData.map { WeeklyLinePoint(label: $0.label, count: $0.count) }

        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: referenceDate)) ?? referenceDate
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) ?? referenceDate
        weekLabel = "\(formatter.string(from: weekStart)) – \(formatter.string(from: weekEnd))"

        let monthData = dataStore.dailySeries(forMonthContaining: referenceDate)
        monthlyPoints = monthData.map { DailyLinePoint(day: $0.day, count: $0.count) }

        let comps = calendar.dateComponents([.year, .month], from: referenceDate)
        if let month = comps.month, let year = comps.year {
            monthLabel = "\(calendar.monthSymbols[month - 1]) \(year)"
            yearLabel = "\(year)"

            let yearlyData = dataStore.monthlySeries(for: year)
            yearlyPoints = yearlyData.map { entry in
                MonthlyLinePoint(
                    month: entry.month,
                    label: calendar.shortMonthSymbols[entry.month - 1],
                    count: entry.count
                )
            }
        }
    }
}

