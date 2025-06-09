//
//  ExerciseData.swift
//  Gymly
//
//  Created by Sebastián Kučera on 13.05.2024.
//


import Foundation
import SwiftData

@Model
class Exercise: Codable {
    @Attribute(.unique) var id: UUID
    var name: String
    var sets: [Set]
    var repGoal: String
    var muscleGroup: String
    var createdAt: Date = Date()
    var animationId = UUID()
    var exerciseOrder: Int
    var done: Bool

    @Relationship(deleteRule: .nullify, inverse: \Day.exercises) var day: Day?

    init(id: UUID = UUID(), name: String, sets: [Set] = [], repGoal: String, muscleGroup: String, createdAt: Date = Date(), animationId: UUID = UUID(), exerciseOrder: Int, done: Bool = false, day: Day? = nil) {
        self.id = id
        self.name = name
        self.sets = sets
        self.repGoal = repGoal
        self.muscleGroup = muscleGroup
        self.createdAt = createdAt
        self.animationId = animationId
        self.exerciseOrder = exerciseOrder
        self.done = done
        self.day = day
    }
    
    func copy() -> Exercise {
        let newExercise = Exercise(
            id: UUID(),  // Ensure a unique ID
            name: self.name,
            sets: [],  // Start with an empty array, avoid duplication
            repGoal: self.repGoal,
            muscleGroup: self.muscleGroup,
            createdAt: self.createdAt,
            animationId: self.animationId,
            exerciseOrder: self.exerciseOrder,
            done: self.done
        )

        // **Deep copy each set without duplication**
        newExercise.sets = self.sets.map { $0.copySets() }
        
        return newExercise
    }
    
    // MARK: - Codable Compliance
    enum CodingKeys: String, CodingKey {
        case id, name, sets, repGoal, muscleGroup, createdAt, exerciseOrder, done
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.sets = try container.decode([Set].self, forKey: .sets)
        self.repGoal = try container.decode(String.self, forKey: .repGoal)
        self.muscleGroup = try container.decode(String.self, forKey: .muscleGroup)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.exerciseOrder = try container.decode(Int.self, forKey: .exerciseOrder)
        self.done = try container.decode(Bool.self, forKey: .done)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(sets, forKey: .sets)
        try container.encode(repGoal, forKey: .repGoal)
        try container.encode(muscleGroup, forKey: .muscleGroup)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(exerciseOrder, forKey: .exerciseOrder)
        try container.encode(done, forKey: .done)
    }
    
    @Model
    class Set: Codable {
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

        @Relationship(deleteRule: .cascade, inverse: \Exercise.sets) var exercise: Exercise?

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
        
        func copySets() -> Set {
            return Set(
                id: UUID(), // Ensure a unique ID
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
        
        
        // MARK: - Codable Compliance
        enum CodingKeys: String, CodingKey {
            case id, weight, reps, failure, warmUp, restPause, dropSet, time, note, createdAt, bodyWeight
        }

        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(UUID.self, forKey: .id)
            self.weight = try container.decode(Double.self, forKey: .weight)
            self.reps = try container.decode(Int.self, forKey: .reps)
            self.failure = try container.decode(Bool.self, forKey: .failure)
            self.warmUp = try container.decode(Bool.self, forKey: .warmUp)
            self.restPause = try container.decode(Bool.self, forKey: .restPause)
            self.dropSet = try container.decode(Bool.self, forKey: .dropSet)
            self.time = try container.decode(String.self, forKey: .time)
            self.note = try container.decode(String.self, forKey: .note)
            self.createdAt = try container.decode(Date.self, forKey: .createdAt)
            self.bodyWeight = try container.decode(Bool.self, forKey: .bodyWeight)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(weight, forKey: .weight)
            try container.encode(reps, forKey: .reps)
            try container.encode(failure, forKey: .failure)
            try container.encode(warmUp, forKey: .warmUp)
            try container.encode(restPause, forKey: .restPause)
            try container.encode(dropSet, forKey: .dropSet)
            try container.encode(time, forKey: .time)
            try container.encode(note, forKey: .note)
            try container.encode(createdAt, forKey: .createdAt)
            try container.encode(bodyWeight, forKey: .bodyWeight)
        }
    }
}
