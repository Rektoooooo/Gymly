//
//  CreateExerciseView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 13.05.2024.
//

import SwiftUI
import SwiftData

struct CreateExerciseView: View {
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State var name:String = ""
    @State var sets:String = ""
    @State var reps:String = ""
    
    @State var muslceGroup:String = "Chest"
    @State var muscleGroups:[String] = ["Chest","Back","Biceps","Triceps","Shoulders","Legs","Abs"]
    
    @State var day:Day
    

    var body: some View {
        NavigationView {
            List {
                Section("Exercise parameters") {
                    TextField("Name", text: $name)
                    TextField("Sets", text: $sets)
                        .keyboardType(.numbersAndPunctuation)
                    TextField("Repeticions", text: $reps)
                        .keyboardType(.numbersAndPunctuation)
                    Picker("Muscle Group", selection: $muslceGroup) {
                        ForEach(muscleGroups, id: \.self) { muscleGroup in
                            Text(muscleGroup)
                        }
                    }
                }
                Section(" ") {
                    Button("Save", action: {
                        if !name.isEmpty && !sets.isEmpty && !reps.isEmpty {
                            createExercise()
                            dismiss()
                        }
                    })
                }

            }
            .navigationTitle("Create exercise")

        }
    }
    
    func createExercise() {
        var setWeightsAdd:[Int] = []
        var setRepsDoneAdd:[Int] = []
        var setFaileurAdd:[Bool] = []

        for _ in 1...Int(sets)! {
            setWeightsAdd.append(1)
            setRepsDoneAdd.append(1)
            setFaileurAdd.append(false)
        }
        day.exercises.insert(Exercise(name: name, sets: Int(sets) ?? 0, reps: Int(reps) ?? 0,muscleGroup: muslceGroup,setWeights: setWeightsAdd,setRepsDone: setRepsDoneAdd,setFailuer: setFaileurAdd), at: day.exercises.endIndex)
        do {
            try context.save()
        } catch {
            debugPrint(error)
        }

    }
}
