//
//  EditExerciseView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 02.09.2025.
//

import SwiftUI

struct EditExerciseView: View {
    /// Environment and observed objects
    @Environment(\.modelContext) private var context
    @EnvironmentObject var config: Config
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: WorkoutViewModel
    @State var exercise: Exercise
    @State private var name: String = ""
    @State private var repetitions: String = ""
    @State private var muscleGroup: String = ""
    @State private var muscleGroups: [String] = []
    var body: some View {
        NavigationView {
            Form {
                Section("Edit name") {
                    TextField("Name", text: $name)
                }
                Section("Edit repetitions") {
                    TextField("Repetitions", text: $repetitions)
                }
                Section("Edit muslce group") {
                    Picker("Muscle Group", selection: $muscleGroup) {
                        ForEach(muscleGroups, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                }
                Section("") {
                    Button("Save") {
                        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmedName.isEmpty { exercise.name = trimmedName }
                        exercise.repGoal = repetitions
                        exercise.muscleGroup = muscleGroup
                        try? context.save()
                        dismiss()
                    }
                }
            }
            .navigationTitle("Edit \(exercise.name)")
        }
        .onAppear {
            self.name = exercise.name
            self.repetitions = exercise.repGoal
            self.muscleGroups = viewModel.muscleGroupNames
            self.muscleGroup = exercise.muscleGroup
        }
    }
}
