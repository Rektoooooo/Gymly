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
class Day: Codable {
    var id: UUID = UUID()
    var name: String = ""
    var dayOfSplit: Int = 0
    var exercises: [Exercise]?
    var date: String = ""

    @Relationship(deleteRule: .cascade, inverse: \Split.days) var split: Split?

    init(id: UUID = UUID(), name: String, dayOfSplit: Int, exercises: [Exercise] = [], date: String, split: Split? = nil) {
        self.id = id
        self.name = name
        self.dayOfSplit = dayOfSplit
        self.exercises = exercises.isEmpty ? nil : exercises
        self.date = date
        self.split = split
    }
    // MARK: - Codable Implementation
    enum CodingKeys: String, CodingKey {
        case id, name, dayOfSplit, exercises, date
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.dayOfSplit = try container.decode(Int.self, forKey: .dayOfSplit)
        self.exercises = try container.decode([Exercise].self, forKey: .exercises)
        self.date = try container.decode(String.self, forKey: .date)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(dayOfSplit, forKey: .dayOfSplit)
        try container.encode(exercises, forKey: .exercises)
        try container.encode(date, forKey: .date)
    }
}
