import Charts
import SwiftUI

struct RecapView: View {
    @EnvironmentObject var viewModel: RecapViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Monthly Trend")
                            .font(.headline)
                        Text(viewModel.monthLabel)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Chart(viewModel.monthlyPoints) { point in
                            LineMark(
                                x: .value("Day", point.day),
                                y: .value("Pushups", point.count)
                            )
                            PointMark(
                                x: .value("Day", point.day),
                                y: .value("Pushups", point.count)
                            )
                        }
                        .frame(height: 240)
                        .chartYScale(domain: 0...(monthlyMax == 0 ? 10 : monthlyMax))
                        .chartXAxis {
                            AxisMarks(values: .stride(by: 5))
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Yearly Trend")
                            .font(.headline)
                        Text(viewModel.yearLabel)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Chart(viewModel.yearlyPoints) { point in
                            LineMark(
                                x: .value("Month", point.label),
                                y: .value("Pushups", point.count)
                            )
                            PointMark(
                                x: .value("Month", point.label),
                                y: .value("Pushups", point.count)
                            )
                        }
                        .frame(height: 240)
                        .chartYScale(domain: 0...(yearlyMax == 0 ? 10 : yearlyMax))
                    }
                }
                .padding()
            }
            .navigationTitle("Trends")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Refresh") {
                        viewModel.refresh()
                    }
                }
            }
        }
    }

    private var monthlyMax: Int {
        viewModel.monthlyPoints.map(\.count).max() ?? 0
    }

    private var yearlyMax: Int {
        viewModel.yearlyPoints.map(\.count).max() ?? 0
    }
}

#Preview {
    RecapView()
        .environmentObject(RecapViewModel())
}



