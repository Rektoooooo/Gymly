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
class Day: DeepCopyable {
    var name: String
    var dayOfSplit: Int
    var exercises: [Exercise]
    var date: String

    // ✅ Mark initializer as `required` to allow `Self.init(...)`
    required init(name: String, dayOfSplit: Int, exercises: [Exercise], date: String) {
        self.name = name
        self.dayOfSplit = dayOfSplit
        self.exercises = exercises
        self.date = date
    }

    // ✅ Implement `copy()`
    func copy() -> Self {
        return Self.init(
            name: self.name,
            dayOfSplit: self.dayOfSplit,
            exercises: self.exercises.map { $0.copy() }, // Deep copy exercises
            date: self.date
        )
    }
}
