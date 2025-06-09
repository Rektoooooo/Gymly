//
//  ExerciseDetailView.swift
//  Gymly
//
//  Created by Sebastián Kučera.
//

import SwiftUI
import SwiftData

struct ExerciseDetailView: View {
    
    /// Environment and observed objects
    @Environment(\.modelContext) private var context
    @EnvironmentObject var config: Config
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: WorkoutViewModel
    @State var exercise: Exercise
    
    /// UI State Variables
    @State private var isOn = false
    @State var showSheet = false
    @State var weight: Double = 0.0
    @State var reps: Int = 0
    @State var failure: Bool = false
    @State var warmUp: Bool = false
    @State var restPause: Bool = false
    @State var dropSet: Bool = false
    @State var setNumber: Int = 0
    @State var bodyWeight: Bool = false
    @State var note: String = ""
    
    /// Converts weight to correct unit (Kg/Lbs)
    var convertedWeight: Double {
        if config.weightUnit == "Kg" {
            return weight
        } else {
            return weight * 2.20462
        }
    }
    
    var body: some View {
        VStack {
            /// Displays set and rep count
            HStack {
                Text("\(exercise.sets.count) Sets")
                    .foregroundStyle(.accent)
                    .padding()
                    .bold()
                Spacer()
                Text("\(exercise.repGoal) Reps")
                    .foregroundStyle(.accent)
                    .padding()
                    .bold()
            }
            Form {
                /// List of exercise sets
                ForEach(Array(exercise.sets.sorted(by: { $0.createdAt < $1.createdAt }).enumerated()), id: \.element.id) { index, set in
                    SetCell(
                        viewModel: viewModel,
                        index: index,
                        set: set,
                        config: config,
                        loadSetData: loadSetData,
                        exercise: exercise,
                        setForCalendar: false
                    )
                }
                /// Dismiss button
                Section("") {
                    Button("Done") {
                        config.activeExercise = exercise.exerciseOrder + 1
                        exercise.done = true
                        dismiss()
                    }
                }
            }
            .toolbar {
                /// Add set button
                Button {
                    Task {
                        await viewModel.addSet(exercise: exercise)
                    }
                } label: {
                    Label("Add set", systemImage: "plus.circle")
                }
            }
        }
        .onAppear {
            /// Load set data when view appears
            for index in exercise.sets.indices {
                loadSetData(set: exercise.sets[index], shouldOpenSheet: false)
            }
        }
        .navigationTitle("\(exercise.name)")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSheet) {
            /// Sheet for editing a set
            EditExerciseSetView(
                weight: $weight,
                reps: $reps,
                unit: $config.weightUnit,
                setNumber: $setNumber,
                note: $note,
                exercise: exercise,
                failure: $failure,
                warmup: $warmUp,
                restPause: $restPause,
                dropSet: $dropSet,
                bodyWeight: $bodyWeight
            )
            .presentationDetents([.fraction(0.65)])
        }
    }
    
    /// Loads set data into state variables for editing
    func loadSetData(set: Exercise.Set, shouldOpenSheet: Bool = true) {
        weight = set.weight
        reps = set.reps
        failure = set.failure
        warmUp = set.warmUp
        restPause = set.restPause
        dropSet = set.dropSet
        bodyWeight = set.bodyWeight
        note = set.note
        setNumber = exercise.sets.firstIndex(where: { $0.id == set.id }) ?? 0
        
        if shouldOpenSheet {
            Task { @MainActor in
                showSheet = true
            }
        }
    }
    
    
    /// Refreshes the exercise data
    func refreshExercise() {
        Task {
            exercise = await viewModel.fetchExercise(id: exercise.id)
        }
    }
}

