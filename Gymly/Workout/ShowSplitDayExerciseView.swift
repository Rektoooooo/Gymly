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
    @Environment(\.colorScheme) var scheme

    /// UI State Variables
    @State var showSheet = false
    @State var sheetType: SheetType?
    @State var selectedSet: Exercise.Set?

    enum SheetType {
        case editExercise
        case editSet(Exercise.Set)
    }
    
    var body: some View {
        ZStack {
            FloatingClouds(theme: CloudsTheme.graphite(scheme))
                .ignoresSafeArea()
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
                        exercise: exercise,
                        setForCalendar: false,  // Enable editing
                        onSetTap: { tappedSet in
                            print("📱 ShowSplitDayExerciseView received set tap for set ID: \(tappedSet.id)")
                            selectedSet = tappedSet
                            sheetType = .editSet(tappedSet)
                            showSheet = true
                        }
                    )
                    .swipeActions(edge: .trailing) {
                        /// Swipe-to-delete action for a set
                        Button(role: .destructive) {
                            viewModel.deleteSet(set, exercise: exercise)
                            refreshExercise()
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
                switch sheetType {
                case .editExercise:
                    EditExerciseView(viewModel: viewModel, exercise: exercise)
                        .presentationDetents([.large])
                case .editSet(let set):
                    EditExerciseSetView(
                        targetSet: set,
                        exercise: exercise,
                        unit: .constant(config.weightUnit)
                    )
                    .onAppear {
                        print("📱 EditExerciseSetView appeared for set ID: \(set.id)")
                    }
                    .onDisappear {
                        print("📱 EditExerciseSetView disappeared for set ID: \(set.id)")
                    }
                case .none:
                    EmptyView()
                }
            }
            .toolbar {
                /// Edit exercise button
                Button {
                    sheetType = .editExercise
                    showSheet = true
                } label: {
                    Label("Edit exercise", systemImage: "slider.horizontal.3")
                }
                /// Add set button
                Button {
                    Task {
                        await viewModel.addSet(exercise: exercise)
                    }
                } label: {
                    Label("Add set", systemImage: "plus.circle")
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .listRowBackground(Color.clear)
        }
        }
        .navigationTitle("\(exercise.name)")
        .navigationBarTitleDisplayMode(.inline)
    }

    /// Refreshes the exercise data
    func refreshExercise() {
        Task {
            exercise = await viewModel.fetchExercise(id: exercise.id)
        }
    }
}
