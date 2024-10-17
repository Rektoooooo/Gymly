//
//  Day.swift
//  Gymly
//
//  Created by Sebastián Kučera on 22.07.2024.
//

import Foundation
import SwiftData

@Model
class Day: Copyable {
    var name: String
    var dayOfSplit: Int
    var exercises:[Exercise]
    var date: String
    
    init(name: String, dayOfSplit: Int, exercises: [Exercise], date: String) {
        self.name = name
        self.dayOfSplit = dayOfSplit
        self.exercises = exercises
        self.date = date
    }
    
    convenience init(from day: Day) {
        // Create deep copies of the exercises as well
        let copiedExercises = day.exercises.map { $0.copy() }
        self.init(name: day.name, dayOfSplit: day.dayOfSplit, exercises: copiedExercises, date: day.date)
    }
}
