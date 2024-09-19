//
//  ExerciseData.swift
//  Gymly
//
//  Created by Sebastián Kučera on 13.05.2024.
//

import Foundation
import SwiftData

@Model
class Exercise: Identifiable{
    var name:String
    var sets:Int
    var reps:Int
    var muscleGroup:String
    var setWeights:[Int]
    var setRepsDone:[Int]
    var setFailuer:[Bool]
    
    init(name:String, sets:Int, reps:Int,muscleGroup:String ,setWeights:[Int], setRepsDone:[Int], setFailuer:[Bool]){
        self.name = name
        self.sets = sets
        self.reps = reps
        self.muscleGroup = muscleGroup
        self.setWeights = setWeights
        self.setRepsDone = setRepsDone
        self.setFailuer = setFailuer
    }
}
