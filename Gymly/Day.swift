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
    @Attribute(.unique) var dayOfWeek: String
    var exercises:[Exercise]
    
    init(name: String, dayOfWeek: String, exercises: [Exercise]) {
        self.name = name
        self.dayOfWeek = dayOfWeek
        self.exercises = exercises
    }
}
