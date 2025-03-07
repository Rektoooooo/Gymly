//
//  Day.swift
//  Gymly
//
//  Created by Sebastián Kučera on 22.07.2024.
//

import Foundation
import SwiftData

protocol DeepCopyable {
    func copy() -> Self
}

@Model
class Day {
    @Attribute(.unique) var id: UUID
    var name: String
    var dayOfSplit: Int 
    var exercises: [Exercise]
    var date: String

    @Relationship(deleteRule: .cascade, inverse: \Split.days) var split: Split?

    init(id: UUID = UUID(), name: String, dayOfSplit: Int, exercises: [Exercise] = [], date: String, split: Split? = nil) {
        self.id = id
        self.name = name
        self.dayOfSplit = dayOfSplit
        self.exercises = exercises
        self.date = date
        self.split = split
    }
}
