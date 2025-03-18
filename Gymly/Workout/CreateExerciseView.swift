//
//  CreateExerciseView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 13.05.2024.
//

import SwiftUI
import SwiftData

struct CreateExerciseView: View {
    
    /// Environment objects for managing state and dismissal
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: WorkoutViewModel
    @State var day: Day
    
    var body: some View {
        NavigationView {
            List {
                /// Section for entering exercise details
                Section("Exercise parameters") {
                    LazyVStack {
                        TextField("Name : Bench Press", text: $viewModel.name)
                    }
                    LazyVStack {
                        TextField("Sets : 3", text: $viewModel.sets)
                            .keyboardType(.numbersAndPunctuation)
                    }
                    LazyVStack {
                        TextField("Repetitions : 8-10", text: $viewModel.reps)
                            .keyboardType(.numbersAndPunctuation)
                    }
                    Picker("Muscle Group", selection: $viewModel.muscleGroup) {
                        ForEach(viewModel.muscleGroupNames, id: \.self) { muscleGroup in
                            Text(muscleGroup)
                        }
                    }
                }
                
                /// Section for saving the exercise
                Section(" ") {
                    Button("Save", action: {
                        debugPrint(day.name)
                        Task {
                            await viewModel.createExercise(to: day)
                        }
                        dismiss()
                    })
                }
            }
            .navigationTitle("Create exercise")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
