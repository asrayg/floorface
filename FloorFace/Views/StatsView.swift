//
//  StatsView.swift
//  NoseTap
//
//  Displays weekly goal progress and trend lines for week, month, and year.
//

import Charts
import SwiftUI
import UIKit

struct StatsView: View {
    @EnvironmentObject var pushupViewModel: PushupViewModel
    @EnvironmentObject var recapViewModel: RecapViewModel
    @Environment(\.scenePhase) private var scenePhase

    @State private var shareImage: UIImage?
    @State private var isSharing = false

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
            .onAppear {
                pushupViewModel.refreshStoredProgress()
                recapViewModel.refresh()
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    pushupViewModel.refreshStoredProgress()
                    recapViewModel.refresh()
                }
            }
            .onChange(of: pushupViewModel.todayCount) { _, _ in
                recapViewModel.refresh()
                pushupViewModel.refreshStoredProgress()
            }
            .sheet(isPresented: $isSharing) {
                if let shareImage {
                    ShareSheet(activityItems: [shareImage])
                }
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
        chartSection(title: "Weekly Trend", subtitle: recapViewModel.weekLabel, shareAction: {
            shareChart(.weekly)
        }) {
            weeklyChartView
        }
    }

    private var monthlyChart: some View {
        chartSection(title: "Monthly Trend", subtitle: recapViewModel.monthLabel, shareAction: {
            shareChart(.monthly)
        }) {
            monthlyChartView
        }
    }

    private var yearlyChart: some View {
        chartSection(title: "Yearly Trend", subtitle: recapViewModel.yearLabel, shareAction: {
            shareChart(.yearly)
        }) {
            yearlyChartView
        }
    }

    private func chartSection<Content: View>(title: String, subtitle: String, shareAction: (() -> Void)? = nil, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if let shareAction {
                    Button(action: shareAction) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .buttonStyle(.plain)
                }
            }
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }

    private var weeklyChartView: some View {
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
        .chartYScale(domain: 0...Double(max(10, weeklyMax)))
    }

    private var monthlyChartView: some View {
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
        .chartYScale(domain: 0...Double(max(10, monthlyMax)))
    }

    private var yearlyChartView: some View {
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
        .chartYScale(domain: 0...Double(max(10, yearlyMax)))
    }

    private enum ChartKind {
        case weekly, monthly, yearly
    }

    private func shareChart(_ kind: ChartKind) {
        let content: AnyView
        let chartWidth: CGFloat = 800
        let chartHeight: CGFloat = 500
        
        switch kind {
        case .weekly:
            content = AnyView(shareableChart(title: "Weekly Trend", subtitle: recapViewModel.weekLabel, chart: weeklyChartView))
        case .monthly:
            content = AnyView(shareableChart(title: "Monthly Trend", subtitle: recapViewModel.monthLabel, chart: monthlyChartView))
        case .yearly:
            content = AnyView(shareableChart(title: "Yearly Trend", subtitle: recapViewModel.yearLabel, chart: yearlyChartView))
        }

        let renderer = ImageRenderer(content: content.frame(width: chartWidth, height: chartHeight))
        renderer.scale = 2.0 // Use 2x scale for better quality
        
        if let image = renderer.uiImage {
            shareImage = image
            isSharing = true
        }
    }

    private func shareableChart<Content: View>(title: String, subtitle: String, chart: Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            chart
                .frame(height: 300)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.white)
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
