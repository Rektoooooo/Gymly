//
//  WorkoutDayView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 13.05.2024.
//

import SwiftUI
import SwiftData

struct ShowSplitDayView: View {
    
    /// State variables for UI control
    @State var name: String = ""
    @State private var createExercise: Bool = false
    @State private var copyWorkout: Bool = false
    @State private var popup: Bool = false
    @State private var days: [Day] = []
    @State var day: Day
    
    /// Environment and observed objects
    @Environment(\.modelContext) private var context
    @EnvironmentObject var config: Config
    @State var muscleGroups: [MuscleGroup] = []
    @ObservedObject var viewModel: WorkoutViewModel
    
    /// Custom initializer
    init(viewModel: WorkoutViewModel, day: Day) {
        self.viewModel = viewModel
        self.day = day
    }
    
    var body: some View {
        VStack {
            List {
                /// Display muscle groups and their exercises
                ForEach(muscleGroups) { group in
                    if !group.exercises.isEmpty {
                        Section(header: Text(group.name)) {
                            ForEach(group.exercises, id: \.id) { exercise in
                                NavigationLink(destination: ShowSplitDayExerciseView(viewModel: viewModel, exercise: exercise)) {
                                    Text(exercise.name)
                                }
                                .swipeActions(edge: .trailing) {
                                    /// Swipe-to-delete action
                                    Button(role: .destructive) {
                                        viewModel.deleteExercise(exercise)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(day.name)
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            Task {
                /// Fetch updated day and refresh muscle groups
                await day = viewModel.fetchDay(dayOfSplit: day.dayOfSplit)
                await refreshMuscleGroups()
            }
        }
        .alert("Enter workout name", isPresented: $popup) {
            /// Popup for editing the workout name
            TextField("Workout name", text: $day.name)
            Button("OK", action: {})
        } message: {
            Text("Enter the name of new section")
        }
        .sheet(isPresented: $createExercise, onDismiss: {
            Task {
                day = await viewModel.fetchDay(dayOfSplit: day.dayOfSplit)
                await refreshMuscleGroups()
            }
        }) {
            CreateExerciseView(viewModel: viewModel, day: viewModel.day)
                .navigationTitle("Create Exercise")
                .presentationDetents([.fraction(0.5)])
        }
        .sheet(isPresented: $copyWorkout, onDismiss: {
            Task {
                day = await viewModel.fetchDay(dayOfSplit: day.dayOfSplit)
                await refreshMuscleGroups()
            }
        }) {
            CopyWorkoutView(viewModel: viewModel, day: day)
                .navigationTitle("Create Exercise")
                .presentationDetents([.fraction(0.25)])
        }
        .toolbar {
            /// Toolbar menu for editing options
            Menu {
                Button(action: {
                    createExercise.toggle()
                }) {
                    Label("Add exercise", systemImage: "plus.square")
                }
                Button(action: {
                    popup.toggle()
                }) {
                    Label("Edit name", systemImage: "square.and.pencil")
                }
                Button(action: {
                    copyWorkout.toggle()
                }) {
                    Label("Copy workout", systemImage: "doc.on.doc")
                }
            } label: {
                Text("Edit")
            }
        }
    }
    
    /// Saves the edited workout name
    func saveDayName() {
        day.name = name
        do {
            try context.save()
        } catch {
            debugPrint(error)
        }
    }
    
    /// Refreshes muscle groups by fetching updated data
    func refreshMuscleGroups() async {
        muscleGroups.removeAll() // Clear array to trigger UI update
        muscleGroups = await viewModel.sortData(dayOfSplit: day.dayOfSplit) // Reassign updated data
    }
}
