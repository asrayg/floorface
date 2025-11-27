//
//  RecapModel.swift
//  NoseTap
//
//  Structures used for recap rendering and sharing.
//

import Foundation
import UIKit

struct MonthlyRecap: Identifiable {
    let id = UUID()
    let monthDate: Date
    let totalPushups: Int
    let bestDay: (date: Date, count: Int)?
    let gifFrames: [UIImage]
    let imageURL: URL?
}

struct YearlyRecap: Identifiable {
    let id = UUID()
    let year: Int
    let totalPushups: Int
    let longestStreak: Int
    let bestMonth: (month: Int, count: Int)?
    let gifFrames: [UIImage]
    let imageURL: URL?
}

