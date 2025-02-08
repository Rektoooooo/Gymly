//
//  WorkoutDayView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 13.05.2024.
//

import SwiftUI
import SwiftData

struct WorkoutDayView: View {
    
    @State var name: String = ""
    @State private var createExercise:Bool = false
    @State private var copyWorkout:Bool = false
    @State private var popup:Bool = false
    @State private var days: [Day] = []
    @State var day: Day
    @Environment(\.modelContext) private var context
    @EnvironmentObject var config: Config
    @State var muscleGroups:[MuscleGroup] = []
    @ObservedObject var viewModel: WorkoutViewModel
    
    init(viewModel: WorkoutViewModel, day: Day) {
        self.viewModel = viewModel
        self.day = day
    }
    
    var body: some View {
        VStack {
            List {
                ForEach(muscleGroups) { group in
                    if !group.exercises.isEmpty {
                        Section(header: Text(group.name)) {
                            ForEach(group.exercises, id: \.id) { exercise in
                                NavigationLink(destination: ExerciseDetailView(viewModel: viewModel, exercise: exercise)) {
                                    Text(exercise.name)
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        deleteItem(exercise)
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
                await day = viewModel.fetchDay(dayOfSplit: day.dayOfSplit)
                await refreshMuscleGroups()
            }
        }
        .alert("Enter workout name", isPresented: $popup) {
            TextField("Workout name", text: $name)
            Button("OK", action: addName)
        } message: {
            Text("Enter the name of new section")
        }
        .sheet(isPresented: $createExercise, content: {
            CreateExerciseView(viewModel: viewModel, day: viewModel.day)
                .navigationTitle("Create Exercise")
        })
        .sheet(isPresented: $copyWorkout, content: {
            CopyWorkoutView(day: day)
                .navigationTitle("Create Exercise")
                .presentationDetents([.fraction(0.25)])
        })
        .toolbar {
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
    
    
    func addName() {
        day.name = name
        do {
            try context.save()
        } catch {
            debugPrint(error)
        }
    }
    
    func deleteItem(_ exercise:Exercise) {
        context.delete(exercise)
        do {
            try context.save()
        } catch {
            debugPrint(error)
        }
        debugPrint("Deleted exercise: \(exercise.name)")
    }
    
    func refreshMuscleGroups() async {
        muscleGroups.removeAll() // Clear array to trigger UI update
        muscleGroups = await viewModel.sortData(dayOfSplit: day.dayOfSplit) // Reassign updated data
    }
    
}

