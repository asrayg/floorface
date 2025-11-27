//
//  RecapGenerator.swift
//  NoseTap
//
//  Creates shareable recap images for monthly and yearly summaries.
//

import Foundation
import UIKit
import ImageIO

final class RecapGenerator {
    static let shared = RecapGenerator()

    private let dataStore: DataStore
    private let calendar: Calendar

    init(dataStore: DataStore = .shared, calendar: Calendar = .current) {
        self.dataStore = dataStore
        self.calendar = calendar
    }

    func monthlyRecap(for date: Date = Date()) -> MonthlyRecap {
        let stats = dataStore.totalForMonth(containing: date)
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        let title = "My Pushup Recap – \(formatter.string(from: date))"
        let frames = sampleGIFFrames(maxCount: 3)
        let image = renderRecapImage(
            title: title,
            summary: "Total pushups: \(stats.total)",
            details: stats.bestDay.map { best in
                let dayFormatter = DateFormatter()
                dayFormatter.dateFormat = "EEEE, MMM d"
                return "Best day: \(dayFormatter.string(from: best.0)) – \(best.1)"
            } ?? "Keep the streak alive!",
            frames: frames,
            type: .monthly
        )
        let url = try? dataStore.saveRecapImage(image, type: .monthly, date: date)
        return MonthlyRecap(monthDate: date, totalPushups: stats.total, bestDay: stats.bestDay, gifFrames: frames, imageURL: url)
    }

    func yearlyRecap(for year: Int = Calendar.current.component(.year, from: Date())) -> YearlyRecap {
        let totals = dataStore.totalForYear(year)
        let title = "My Pushup Year – \(year)"
        let streak = dataStore.streakCount()
        var bestDescriptor = "Keep building momentum"
        if let bestMonth = totals.bestMonth {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "LLLL"
            var comps = DateComponents()
            comps.year = year
            comps.month = bestMonth.0
            comps.day = 1
            if let bestDate = calendar.date(from: comps) {
                bestDescriptor = "Best month: \(dateFormatter.string(from: bestDate)) – \(bestMonth.1)"
            }
        }
        let frames = sampleGIFFrames(maxCount: 6)
        let image = renderRecapImage(
            title: title,
            summary: "Total pushups: \(totals.total)",
            details: "Streaks: \(streak) days\n\(bestDescriptor)",
            frames: frames,
            type: .yearly
        )
        let yearDate = calendar.date(from: DateComponents(year: year)) ?? Date()
        let url = try? dataStore.saveRecapImage(image, type: .yearly, date: yearDate)
        return YearlyRecap(year: year, totalPushups: totals.total, longestStreak: streak, bestMonth: totals.bestMonth, gifFrames: frames, imageURL: url)
    }

    // MARK: - Private helpers

    private func sampleGIFFrames(maxCount: Int) -> [UIImage] {
        var images: [UIImage] = []
        let urls = dataStore.gifURLs().shuffled()
        for url in urls {
            guard let data = try? Data(contentsOf: url),
                  let source = CGImageSourceCreateWithData(data as CFData, nil) else {
                continue
            }
            let frameCount = CGImageSourceGetCount(source)
            guard frameCount > 0 else { continue }
            let index = Int.random(in: 0..<frameCount)
            if let cgImage = CGImageSourceCreateImageAtIndex(source, index, nil) {
                images.append(UIImage(cgImage: cgImage))
            }
            if images.count == maxCount { break }
        }
        return images
    }

    private func renderRecapImage(title: String, summary: String, details: String, frames: [UIImage], type: RecapType) -> UIImage {
        let size = CGSize(width: 1080, height: 1920)
        let renderer = UIGraphicsImageRenderer(size: size)
        let fontTitle = UIFont.systemFont(ofSize: 48, weight: .bold)
        let fontSummary = UIFont.systemFont(ofSize: 32, weight: .semibold)
        let fontDetails = UIFont.systemFont(ofSize: 28, weight: .regular)

        return renderer.image { context in
            UIColor.black.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: fontTitle,
                .foregroundColor: UIColor.white
            ]
            let summaryAttributes: [NSAttributedString.Key: Any] = [
                .font: fontSummary,
                .foregroundColor: UIColor.systemGreen
            ]
            let detailsAttributes: [NSAttributedString.Key: Any] = [
                .font: fontDetails,
                .foregroundColor: UIColor.white
            ]

            let margin: CGFloat = 40
            var yOffset: CGFloat = margin

            let titleRect = CGRect(x: margin, y: yOffset, width: size.width - margin * 2, height: 200)
            title.draw(in: titleRect, withAttributes: titleAttributes)
            yOffset += 160

            summary.draw(in: CGRect(x: margin, y: yOffset, width: size.width - margin * 2, height: 100), withAttributes: summaryAttributes)
            yOffset += 100

            details.draw(in: CGRect(x: margin, y: yOffset, width: size.width - margin * 2, height: 200), withAttributes: detailsAttributes)
            yOffset += 220

            let columns = type == .monthly ? 3 : 3
            let rows = type == .monthly ? 1 : 2
            let frameWidth = (size.width - margin * 2 - CGFloat(columns - 1) * 20) / CGFloat(columns)
            let frameHeight: CGFloat = 200

            for (index, image) in frames.enumerated() {
                guard index < columns * rows else { break }
                let row = index / columns
                let column = index % columns
                let x = margin + CGFloat(column) * (frameWidth + 20)
                let y = yOffset + CGFloat(row) * (frameHeight + 20)
                let rect = CGRect(x: x, y: y, width: frameWidth, height: frameHeight)
                image.draw(in: rect)
            }
        }
    }
}

