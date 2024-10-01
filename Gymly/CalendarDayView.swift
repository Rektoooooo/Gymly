//
//  CalendarDayView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 30.09.2024.
//

import SwiftUI
import SwiftData

struct CalendarDayView: View {
    var day: String
    @State var days: [DayStorage] = []
    @State private var exercises: [Exercise] = []
    @State var muscleGroupNames:[String] = ["Chest","Back","Biceps","Triceps","Shoulders","Legs","Abs"]
    @State var muscleGroups:[MuscleGroup] = []
    @Environment(\.modelContext) private var context
    var body: some View {
        NavigationView {
            List {
                ForEach(muscleGroups, id: \.self) { muscleGroup in
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
            }
            .navigationTitle(days.first?.day.name ?? "No exercises recorded")
        }
        .onAppear() {
            fetchData()
        }
    }
    
    
    private func fetchData() {
        let predicate = #Predicate<DayStorage> {
            $0.date == day
        }
        let descriptor = FetchDescriptor<DayStorage>(predicate: predicate)
        do {
            let fetchedData = try context.fetch(descriptor)
            days = []
            exercises = []
            days = fetchedData
            if days.isEmpty {
                debugPrint("No day found for date : \(day)")
            } else {
                muscleGroups = []
                for exercise in days[0].day.exercises {
                    exercises.append(exercise)
                    debugPrint("Appended exercise: \(exercise.name) \(exercise.muscleGroup) \(exercise.sets) \(exercise.repGoal)")
                }
                for name: String in muscleGroupNames {
                    let exercises = exercises.filter { exercise in
                        return exercise.muscleGroup.contains(name)
                    }
                    let group = MuscleGroup(name: name, count: 0, exercises: exercises)
                    muscleGroups.append(group)
                }
            }
        } catch {
            debugPrint("Error fetching data: \(error)")
        }
    }

}

