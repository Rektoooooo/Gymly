//
//  Day.swift
//  Gymly
//
//  Created by Sebastián Kučera on 22.07.2024.
//

import Foundation
import SwiftData

// ✅ Rename to avoid conflicts
protocol DeepCopyable {
    func copy() -> Self
}

@Model
class Day {
    @Attribute(.unique) var id: UUID
    var name: String
    var dayOfSplit: Int // 1 = Monday, 2 = Tuesday...
    var exercises: [Exercise] // Exercises for this day
    var date: String // Formatted date

    @Relationship(deleteRule: .cascade, inverse: \Split.days) var split: Split? // ✅ Each Day belongs to one Split

    init(id: UUID = UUID(), name: String, dayOfSplit: Int, exercises: [Exercise] = [], date: String, split: Split? = nil) {
        self.id = id
        self.name = name
        self.dayOfSplit = dayOfSplit
        self.exercises = exercises
        self.date = date
        self.split = split
    }
}
