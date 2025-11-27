import Foundation

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
    @Published var monthlyPoints: [DailyLinePoint] = []
    @Published var yearlyPoints: [MonthlyLinePoint] = []
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
        let monthData = dataStore.dailySeries(forMonthContaining: referenceDate)
        monthlyPoints = monthData.map { DailyLinePoint(day: $0.day, count: $0.count) }

        let comps = calendar.dateComponents([.year, .month], from: referenceDate)
        if let month = comps.month, let year = comps.year {
            let formatter = DateFormatter()
            formatter.calendar = calendar
            monthLabel = "\(formatter.monthSymbols[month - 1]) \(year)"
            yearLabel = "\(year)"

            let yearlyData = dataStore.monthlySeries(for: year)
            yearlyPoints = yearlyData.map { entry in
                MonthlyLinePoint(
                    month: entry.month,
                    label: formatter.shortMonthSymbols[entry.month - 1],
                    count: entry.count
                )
            }
        }
    }
}

