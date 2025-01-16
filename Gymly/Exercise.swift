//
//  ExerciseData.swift
//  Gymly
//
//  Created by Sebastián Kučera on 13.05.2024.
//

import Foundation
import SwiftData

@Model
class Exercise: Identifiable, Copyable {
    var id: UUID
    var name:String
    var sets: [Set]
    var repGoal:Int
    var muscleGroup:String
    
    
    init(id: UUID, name:String, sets: [Set], repGoal:Int, muscleGroup:String) {
        self.id = id
        self.name = name
        self.sets = sets
        self.repGoal = repGoal
        self.muscleGroup = muscleGroup
    }
    
    func copy() -> Exercise {
        return Exercise(id: self.id, name: self.name, sets: self.sets, repGoal: self.repGoal, muscleGroup: self.muscleGroup)
    }
    
    @Model
    class Set: Identifiable, Copyable {
        var weight:Int
        var reps:Int
        var failure:Bool
        var warmUp:Bool
        var restPause:Bool
        var dropSet:Bool
        var time:String
        var note:String
        var createdAt: Date
        
        static func createDefault() -> Set {
            return Set(
                weight: 0, reps: 0, failure: false, time: "", note: "", warmUp: false, restPause: false, dropSet: false, createdAt: Date()
            )
        }
        
        init(weight:Int, reps:Int, failure:Bool, time:String, note:String?, warmUp:Bool, restPause:Bool, dropSet:Bool, createdAt:Date) {
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
    }

}


