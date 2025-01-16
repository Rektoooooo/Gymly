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
    @ObservedObject var viewModel: WorkoutViewModel

    @State var day:Day
    
    var body: some View {
        NavigationView {
            List {
                Section("Exercise parameters") {
                    LazyVStack {
                        TextField("Name", text: $viewModel.name)
                    }
                    LazyVStack {
                        TextField("Sets", text: $viewModel.sets)
                            .keyboardType(.numbersAndPunctuation)
                    }
                    LazyVStack {
                        TextField("Repeticions", text: $viewModel.reps)
                        .keyboardType(.numbersAndPunctuation)
                    }
                    Picker("Muscle Group", selection: $viewModel.muslceGroup) {
                        ForEach(viewModel.muscleGroupNames, id: \.self) { muscleGroup in
                            Text(muscleGroup)
                        }
                    }
                }
                Section(" ") {
                    Button("Save", action: {
                        debugPrint(day.name)
                        Task {
                            await viewModel.createExercise()
                        }
                            dismiss()
                    })
                }

            }
            .navigationTitle("Create exercise for \(day.name)")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    

}
