//
//  TodayWorkoutView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 20.08.2024.
//

import SwiftUI
import Foundation
import SwiftData

struct TodayWorkoutView: View {
    
    @ObservedObject var viewModel: WorkoutViewModel
    @EnvironmentObject var config: Config
    @Environment(\.modelContext) var context: ModelContext
    
    @State private var navigationTitle: String = ""
    @State var muscleGroups:[MuscleGroup] = []
    
    var body: some View {
        NavigationView{
            List {
                ForEach(muscleGroups) { group in
                    if !group.exercises.isEmpty {
                        Section(header: Text(group.name)) {
                            ForEach(group.exercises, id: \.id) { exercise in
                                NavigationLink(destination: ExerciseDetailView(viewModel: viewModel, exercise: exercise)) {
                                    Text(exercise.name)
                                }
                            }
                        }
                    }
                }
                Section("") {
                    Button("Workout done") {
                        Task {
                            await viewModel.insertWorkout()
                        }
                    }
                }
            }
            .id(UUID())
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.large)
            .onChange(of: viewModel.addExercise) {
                Task {
                    await refreshMuscleGroups()
                }
            }
            .toolbar {
                Button {
                    viewModel.editPlan = true
                } label: {
                    Label("", systemImage: "ellipsis.circle")
                }
                Button {
                    viewModel.addExercise = true
                } label: {
                    Label("", systemImage: "plus.circle")
                }
            }
        }
        .task {
            // Call sortData asynchronously when the view appears
            config.dayInSplit = viewModel.updateDayInSplit()
            config.lastUpdateDate = Date()
            await refreshMuscleGroups()
            navigationTitle = viewModel.day.name

        }
        .sheet(isPresented: $viewModel.editPlan, onDismiss: {
            Task {
                await refreshMuscleGroups()
            }
        }) {
            SplitView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.addExercise, onDismiss: {
            Task {
                await refreshMuscleGroups()
            }
        } ,content: {
                CreateExerciseView(viewModel: viewModel, day: viewModel.day)
                    .navigationTitle("Create Exercise")
                    .presentationDetents([.fraction(0.5)])
                
            })
        }
    
    func refreshMuscleGroups() async {
        muscleGroups.removeAll() // Clear array to trigger UI update
        muscleGroups = await viewModel.sortData(dayOfSplit: config.dayInSplit) // Reassign updated data
    }
    
}

