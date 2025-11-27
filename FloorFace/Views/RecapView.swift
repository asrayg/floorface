//
//  RecapView.swift
//  NoseTap
//
//  Displays monthly and yearly recap cards with sharing.
//

import SwiftUI
import UIKit

struct RecapView: View {
    @EnvironmentObject var viewModel: RecapViewModel
    @State private var shareItems: [Any] = []
    @State private var showShareSheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    recapCard(title: "Monthly Recap", image: viewModel.monthlyRecap?.imageURL, frames: viewModel.monthlyRecap?.gifFrames ?? [], summary: monthlySummary, action: {
                        shareRecap(imageURL: viewModel.monthlyRecap?.imageURL)
                    })

                    recapCard(title: "Yearly Recap", image: viewModel.yearlyRecap?.imageURL, frames: viewModel.yearlyRecap?.gifFrames ?? [], summary: yearlySummary, action: {
                        shareRecap(imageURL: viewModel.yearlyRecap?.imageURL)
                    })
                }
                .padding()
            }
            .navigationTitle("Recaps")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Refresh") {
                        viewModel.generateMonthlyRecap()
                        viewModel.generateYearlyRecap()
                    }
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: shareItems)
        }
    }

    private func recapCard(title: String, image: URL?, frames: [UIImage], summary: String, action: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)

            if let image, let uiImage = UIImage(contentsOfFile: image.path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(12)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 220)
                    .overlay {
                        ProgressView()
                    }
                    .cornerRadius(12)
            }

            Text(summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if !frames.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(Array(frames.enumerated()), id: \.offset) { item in
                            Image(uiImage: item.element)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipped()
                                .cornerRadius(8)
                        }
                    }
                }
            }

            Button("Share") {
                action()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }

    private var monthlySummary: String {
        guard let recap = viewModel.monthlyRecap else {
            return "Generating monthly recap..."
        }
        if let bestDay = recap.bestDay {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return "Total: \(recap.totalPushups) • Best day: \(formatter.string(from: bestDay.date))"
        }
        return "Total: \(recap.totalPushups)"
    }

    private var yearlySummary: String {
        guard let recap = viewModel.yearlyRecap else {
            return "Generating yearly recap..."
        }
        var text = "Total: \(recap.totalPushups) • Streak: \(recap.longestStreak)"
        if let bestMonth = recap.bestMonth {
            var comps = DateComponents()
            comps.month = bestMonth.month
            comps.day = 1
            let formatter = DateFormatter()
            formatter.dateFormat = "LLLL"
            if let date = Calendar.current.date(from: comps) {
                text.append(" • Best month \(formatter.string(from: date))")
            }
        }
        return text
    }

    private func shareRecap(imageURL: URL?) {
        guard let imageURL else { return }
        shareItems = [imageURL]
        showShareSheet = true
    }
}

#Preview {
    RecapView()
        .environmentObject(RecapViewModel())
}

