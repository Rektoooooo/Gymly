//
//  ShowSplitDayExerciseView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 09.02.2025.
//


import SwiftUI
import SwiftData

struct ShowSplitDayExerciseView: View {
    
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
    @State var bodyWeight: Bool = false
    @State var setNumber: Int = 0
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
                    Section("Set \(index + 1)") {
                        Button {
                            loadSetData(set: set)
                        } label: {
                            HStack {
                                /// Display set details (weight, reps, notes)
                                HStack {
                                    if set.bodyWeight {
                                        Text("BW  +")
                                            .foregroundStyle(.accent)
                                            .bold()
                                    }
                                    Text("\(Int(round(Double(set.weight) * (config.weightUnit == "Kg" ? 1.0 : 2.20462))))")
                                        .foregroundStyle(.accent)
                                        .bold()
                                    Text("\(config.weightUnit)")
                                        .foregroundStyle(.accent)
                                        .opacity(0.6)
                                        .offset(x: -5)
                                }
                                HStack {
                                    Text("\(set.reps)")
                                        .foregroundStyle(Color.green)
                                        .bold()
                                    Text("Reps")
                                        .foregroundStyle(Color.green)
                                        .opacity(0.6)
                                        .offset(x: -5)
                                }
                                HStack {
                                    if set.failure {
                                        Text("F")
                                            .foregroundStyle(Color.red)
                                            .offset(x: -5)
                                    }
                                    if set.warmUp {
                                        Text("W")
                                            .foregroundStyle(Color.orange)
                                            .offset(x: -5)
                                    }
                                    if set.restPause {
                                        Text("RP")
                                            .foregroundStyle(Color.green)
                                            .offset(x: -5)
                                    }
                                    if set.dropSet {
                                        Text("DS")
                                            .foregroundStyle(Color.blue)
                                            .offset(x: -5)
                                    }
                                }
                                Spacer()
                                Text("\(set.time)")
                                    .foregroundStyle(Color.white)
                                    .opacity(set.time.isEmpty ? 0 : 0.3)
                            }
                        }
                        if !set.note.isEmpty {
                            Text(set.note)
                                .foregroundStyle(Color.white)
                                .opacity(0.5)
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        /// Swipe-to-delete action for a set
                        Button(role: .destructive) {
                            deleteItem(set)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                
                /// Dismiss button
                Section("") {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
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
            .toolbar {
                /// Add set button
                Button {
                    Task {
                        await addSet()
                    }
                } label: {
                    Label("Add set", systemImage: "plus.circle")
                }
            }
        }
        .navigationTitle("\(exercise.name)")
        .navigationBarTitleDisplayMode(.inline)
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
    
    /// Deletes a set from the exercise
    func deleteItem(_ set: Exercise.Set) {
        if let index = exercise.sets.firstIndex(where: { $0.id == set.id }) {
            withAnimation {
                _ = exercise.sets.remove(at: index)
            }
        }
        context.delete(set)
        refreshExercise()
    }
    
    /// Adds a new set to the exercise
    func addSet() async {
        let newSet = Exercise.Set.createDefault()
        exercise.sets.append(newSet)
        
        do {
            try context.save()
            refreshExercise()
        } catch {
            debugPrint(error)
        }
    }
    
    /// Refreshes the exercise data
    func refreshExercise() {
        Task {
            exercise = await viewModel.fetchExercise(id: exercise.id)
        }
    }
}
