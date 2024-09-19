//
//  ExerciseData.swift
//  Gymly
//
//  Created by Sebastián Kučera on 13.05.2024.
//

import Foundation
import SwiftData

@Model
class Exercise: Identifiable {
    var name:String
    var sets: [Set]
    var repGoal:Int
    var muscleGroup:String
    
    
    init(name:String, sets: [Set], repGoal:Int, muscleGroup:String) {
        self.name = name
        self.sets = sets
        self.repGoal = repGoal
        self.muscleGroup = muscleGroup
    }
    
    @Model
    class Set: Identifiable {
        var weight:Int
        var reps:Int
        var failure:Bool
        
        init(weight: Int, reps: Int, failure: Bool) {
            self.weight = weight
            self.reps = reps
            self.failure = failure
        }
    }
}


