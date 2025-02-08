//
//  ExerciseData.swift
//  Gymly
//
//  Created by Sebastián Kučera on 13.05.2024.
//


import Foundation
import SwiftData

// Place Copyable at the top
protocol Copyable {
    func copy() -> Self
}

@Model
class Exercise: Identifiable, Copyable {
    var id: UUID
    var name: String
    var sets: [Set]
    var repGoal: Int
    var muscleGroup: String

    required init(id: UUID, name: String, sets: [Set], repGoal: Int, muscleGroup: String) {
        self.id = id
        self.name = name
        self.sets = sets
        self.repGoal = repGoal
        self.muscleGroup = muscleGroup
    }

    func copy() -> Self {
        return Self.init(
            id: UUID(), // Ensure a unique ID
            name: self.name,
            sets: self.sets.map { $0.copy() }, // Copy each set
            repGoal: self.repGoal,
            muscleGroup: self.muscleGroup
        )
    }
    

    @Model
    class Set: Identifiable, Copyable {
        var weight: Int
        var reps: Int
        var failure: Bool
        var warmUp: Bool
        var restPause: Bool
        var dropSet: Bool
        var time: String
        var note: String
        var createdAt: Date

        required init(weight: Int, reps: Int, failure: Bool, time: String, note: String?, warmUp: Bool, restPause: Bool, dropSet: Bool, createdAt: Date) {
            self.weight = weight
            self.reps = reps
            self.failure = failure
            self.time = time
            self.note = note ?? ""
            self.warmUp = warmUp
            self.restPause = restPause
            self.dropSet = dropSet
            self.createdAt = createdAt
        }
        
        static func createDefault() -> Set {
            return Set(
                weight: 0, reps: 0, failure: false, time: "", note: "", warmUp: false, restPause: false, dropSet: false, createdAt: Date()
            )
        }

        func copy() -> Self {
            return Self.init(
                weight: self.weight,
                reps: self.reps,
                failure: self.failure,
                time: self.time,
                note: self.note,
                warmUp: self.warmUp,
                restPause: self.restPause,
                dropSet: self.dropSet,
                createdAt: self.createdAt
            )
        }
    }
}
