//
//  Day.swift
//  Gymly
//
//  Created by Sebastián Kučera on 22.07.2024.
//

import Foundation
import SwiftData

@Model
class Day {
    var name: String
    var dayOfWeek: String
    var exercises:[Exercise]
    var date: String
    
    init(name: String, dayOfWeek: String, exercises: [Exercise], date: String) {
        self.name = name
        self.dayOfWeek = dayOfWeek
        self.exercises = exercises
        self.date = date
    }
}
