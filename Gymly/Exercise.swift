//
//  ExerciseData.swift
//  Gymly
//
//  Created by Sebastián Kučera on 13.05.2024.
//


import Foundation
import SwiftData

@Model
class Exercise {
    @Attribute(.unique) var id: UUID
    var name: String
    var sets: [Set] // ✅ List of sets
    var repGoal: Int
    var muscleGroup: String
    var createdAt: Date = Date()

    @Relationship(deleteRule: .nullify, inverse: \Day.exercises) var day: Day? // ✅ Each Exercise belongs to a Day

    init(id: UUID = UUID(), name: String, sets: [Set] = [], repGoal: Int, muscleGroup: String,createdAt: Date = Date(), day: Day? = nil) {
        self.id = id
        self.name = name
        self.sets = sets
        self.repGoal = repGoal
        self.muscleGroup = muscleGroup
        self.createdAt = createdAt
        self.day = day
    }
    
    // ✅ Deep copy function
    func copy() -> Exercise {
        return Exercise(
            name: self.name,
            sets: self.sets.map { $0.copySets() }, // ✅ Deep copy all sets
            repGoal: self.repGoal,
            muscleGroup: self.muscleGroup,
            createdAt: self.createdAt
        )
    }
    
    @Model
    class Set {
        @Attribute(.unique) var id: UUID
        var weight: Double
        var reps: Int
        var failure: Bool
        var warmUp: Bool
        var restPause: Bool
        var dropSet: Bool
        var time: String
        var note: String
        var createdAt: Date
        var bodyWeight: Bool

        @Relationship(deleteRule: .cascade, inverse: \Exercise.sets) var exercise: Exercise? // ✅ Each Set belongs to an Exercise

        init(id: UUID = UUID(), weight: Double, reps: Int, failure: Bool, warmUp: Bool, restPause: Bool, dropSet: Bool, time: String, note: String, createdAt: Date, bodyWeight: Bool, exercise: Exercise? = nil) {
            self.id = id
            self.weight = weight
            self.reps = reps
            self.failure = failure
            self.warmUp = warmUp
            self.restPause = restPause
            self.dropSet = dropSet
            self.time = time
            self.note = note
            self.createdAt = createdAt
            self.bodyWeight = bodyWeight
            self.exercise = exercise
        }
        
        static func createDefault() -> Set {
            return Set(
                id: UUID(), weight: 0.0, reps: 0, failure: false, warmUp: false, restPause: false, dropSet: false, time: "", note: "", createdAt: Date(), bodyWeight: false
            )
        }
        
        // ✅ Deep copy function
        func copySets() -> Set {
            return Set(
                weight: self.weight,
                reps: self.reps,
                failure: self.failure,
                warmUp: self.warmUp,
                restPause: self.restPause,
                dropSet: self.dropSet,
                time: self.time,
                note: self.note,
                createdAt: self.createdAt,
                bodyWeight: self.bodyWeight
            )
        }
    }
}
