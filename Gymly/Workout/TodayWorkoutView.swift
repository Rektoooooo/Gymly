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
    
    @StateObject private var viewModel = WorkoutViewModel()
    @EnvironmentObject var config: Config
    @Environment(\.modelContext) private var context
    
    
    var body: some View {
        NavigationView{
            List {
                ForEach(viewModel.muscleGroups, id: \.self) { muscleGroup in
                    if !muscleGroup.exercises.isEmpty {
                        Section(header: Text(muscleGroup.name)) {
                            ForEach(muscleGroup.exercises, id: \.self) { exercise in
                                NavigationLink("\(exercise.name)") {
                                    ExerciseDetailView(exercise: exercise)
                                }
                            }
                        }
                    }
                }
                Section("") {
                    Button("Workout done") {
                        viewModel.insertWorkout(context: context)
                    }
                }
            }
            .id(UUID())
            .navigationTitle(viewModel.day.name)
            .navigationBarTitleDisplayMode(.large)
            .onChange(of: viewModel.addExercise) {
                Task {
                    await viewModel.fetchData(context: context, dayInSplit: config.dayInSplit)
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
        .onAppear {
            config.dayInSplit = viewModel.updateDayInSplit(lastUpdatedDate: config.lastUpdateDate, splitLength: config.splitLenght, dayInSplit: config.dayInSplit)
            config.lastUpdateDate = Date()
            Task {
                await viewModel.fetchData(context: context, dayInSplit: config.dayInSplit)
            }
        }
        .sheet(isPresented: $viewModel.editPlan, onDismiss: {
            Task {
                await viewModel.fetchData(context: context, dayInSplit: config.dayInSplit)
            }
        }) {
            SplitView()
        }
        .sheet(isPresented: $viewModel.addExercise, onDismiss: {
            Task {
                await viewModel.fetchData(context: context, dayInSplit: config.dayInSplit)
            }
        } ,content: {
            CreateExerciseView(day: viewModel.day)
                .navigationTitle("Create Exercise")
                .presentationDetents([.fraction(0.5)])
        })
    }
}

