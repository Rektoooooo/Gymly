//
//  MuscleGroup.swift
//  Gymly
//
//  Created by Sebastián Kučera on 19.09.2024.
//

import Foundation

class MuscleGroup {
    let name: String
    var count: Int
    var exercises: [Exercise]
    
    init(name: String, count: Int, exercises: [Exercise]) {
        self.name = name
        self.count = count
        self.exercises = exercises
    }
}

extension MuscleGroup: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

extension MuscleGroup: Equatable {
    static func == (lhs: MuscleGroup, rhs: MuscleGroup) -> Bool {
        return lhs.name == rhs.name
    }
}

