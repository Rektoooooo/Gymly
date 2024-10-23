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
    @State var day:Day
    
    @StateObject private var viewModelVariables = SetVariablesViewModel()

    var body: some View {
        NavigationView {
            List {
                Section("Exercise parameters") {
                    LazyVStack {
                        TextField("Name", text: $name)
                        
                    }
                    LazyVStack {
                        TextField("Sets", text: $sets)
                            .keyboardType(.numbersAndPunctuation)
                    }
                    LazyVStack {
                    TextField("Repeticions", text: $reps)
                        .keyboardType(.numbersAndPunctuation)
                    }
                    Picker("Muscle Group", selection: $muslceGroup) {
                        ForEach(viewModelVariables.muscleGroupNames, id: \.self) { muscleGroup in
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
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func createExercise() {
        var setList: [Exercise.Set] = []
        for _ in 1...Int(sets)! {
            let set = Exercise.Set(weight: 0, reps: 0, failure: false, time: "")
            setList.append(set)
        }
        day.exercises.insert(Exercise(
            name: name,
            sets: setList,
            repGoal: Int(reps) ?? 0,
            muscleGroup: muslceGroup),
                             at : day.exercises.endIndex)
        do {
            try context.save()
        } catch {
            debugPrint(error)
        }

    }
}
