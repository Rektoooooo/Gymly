//
//  WorkoutDayView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 13.05.2024.
//

import SwiftUI
import SwiftData

struct WorkoutDayView: View {
    
    @State var name:String
    @State private var createExercise:Bool = false
    @State private var copyWorkout:Bool = false
    @State private var popup:Bool = false
    @State private var days: [Day] = []
    @State var day:Day
    @Environment(\.modelContext) private var context
    
    @StateObject private var viewModelVariables = SetVariablesViewModel()
    
    var body: some View {
        VStack {
            List {
                ForEach(viewModelVariables.muscleGroupNames, id: \.self) { muscle in
                    let exercisesForMuscle = day.exercises.filter { $0.muscleGroup == muscle }
                    if !exercisesForMuscle.isEmpty {
                        Section(header: Text(muscle)) {
                            ForEach(exercisesForMuscle, id: \.self) { exercise in
                                NavigationLink("\(exercise.name)") {
                                    ExerciseDetailView(exercise: exercise)
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        debugPrint(exercise.name)
                                    } label: {
                                        Label("Unread", systemImage: "printer.fill")
                                    }
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
            fetchData()
            day = days[0]
        }
        .alert("Enter workout name", isPresented: $popup) {
            TextField("Workout name", text: $name)
            Button("OK", action: addName)
        } message: {
            Text("Enter the name of new section")
        }
        .sheet(isPresented: $createExercise, content: {
            CreateExerciseView(day: day)
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
    
    private func fetchData() {
        let predicate = #Predicate<Day> {
            $0.name == name
        }
        let descriptor = FetchDescriptor<Day>(predicate: predicate)
        do {
            let fetchedData = try context.fetch(descriptor)
            days = fetchedData
            if days.isEmpty {
                debugPrint("No day found for name: \(name)")
            } else {
                debugPrint("Fetched day: \(days[0].name)")
            }
        } catch {
            debugPrint("Error fetching data: \(error)")
        }
    }


}

