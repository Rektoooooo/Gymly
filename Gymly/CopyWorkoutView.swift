//
//  CopyWorkout.swift
//  Gymly
//
//  Created by Sebastián Kučera on 12.09.2024.
//

import SwiftUI
import SwiftData

struct CopyWorkoutView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    @State var day:Day
    @State private var days: [Day] = []
    @State var workoutNames: [String] = []
    @State var selected: String = ""
    @State private var selectedDays: [Day] = []
    @State var fetchedExercises: [Exercise] = []
    var sortedDays: [Day] {
        let weekdaysOrder = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        return days.sorted {
            guard let firstIndex = weekdaysOrder.firstIndex(of: $0.dayOfWeek),
                  let secondIndex = weekdaysOrder.firstIndex(of: $1.dayOfWeek) else {
                return false
            }
            return firstIndex < secondIndex
        }
    }
    

    var body: some View {
        NavigationView {
            List {
                Picker("Chose workout", selection: $selected) {
                    ForEach(workoutNames, id: \.self) {
                        Text($0 )
                    }
                    .pickerStyle(.inline)
                }
                Button("Copy \(selected)") {
                    copyWorkout()
                    dismiss()
                }
            }
            .onAppear {
                selected = day.name
                fetchData()
                for i in 0...days.count - 1 {
                    workoutNames.append(sortedDays[i].name)
                }
            }
        }
    }
    
    func copyWorkout() {
        fetchDayToCopy()

        let copiedExercises = fetchedExercises.map { originalExercise -> Exercise in
            return Exercise(name:originalExercise.name, sets: originalExercise.sets, repGoal:originalExercise.repGoal, muscleGroup:originalExercise.muscleGroup)
        }

        day.exercises = copiedExercises

        do {
            try context.save()
            debugPrint("Workout copied successfully")
        } catch {
            debugPrint("Error saving context: \(error)")
        }
    }

    
    func fetchDayToCopy() {
        let predicate = #Predicate<Day> {
            $0.name == selected
        }
        let descriptor = FetchDescriptor<Day>(predicate: predicate)
        do {
            let fetchedData = try context.fetch(descriptor)
            selectedDays = fetchedData
            fetchedExercises = selectedDays[0].exercises
            debugPrint("\(fetchedExercises)")
            if days.isEmpty {
                debugPrint("No day found for name:")
            } else {
                debugPrint("Fetched days: \(selectedDays[0].name)")
            }
        } catch {
            debugPrint("Error fetching data: \(error)")
        }
    }
    
    
    func fetchData() {
        let predicate = #Predicate<Day> {
            $0.name == $0.name
        }
        let descriptor = FetchDescriptor<Day>(predicate: predicate)
        do {
            let fetchedData = try context.fetch(descriptor)
            days = fetchedData
            
            if days.isEmpty {
                debugPrint("No day found for name:")
            } else {
//                for i in 0...days.count - 1 {
//                    workoutNames.insert(days[i].name, at: 0)
//                    debugPrint(days[i].name)
//                }
                debugPrint("Fetched days: \(days)")
            }
        } catch {
            debugPrint("Error fetching data: \(error)")
        }
    }
    
    
}

