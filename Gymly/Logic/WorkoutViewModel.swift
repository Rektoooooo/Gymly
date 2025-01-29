//
//  WorkoutViewModel.swift
//  Gymly
//
//  Created by Sebastián Kučera on 23.10.2024.
//

import Foundation
import SwiftData
import SwiftUI

final class WorkoutViewModel: ObservableObject {
    
    @Published var days: [Day] = []
    @Published var exercises:[Exercise] = []
    @Published var day:Day = Day(name: "", dayOfSplit: 0, exercises: [],date: "")
    @Published var muscleGroups:[MuscleGroup] = []
    @Published var editPlan:Bool = false
    @Published var addExercise:Bool = false
    @Published var muscleGroupNames:[String] = ["Chest","Back","Biceps","Triceps","Shoulders","Legs","Abs"]
    @Published var exerciseId: UUID? = nil
    @Published var name:String = ""
    @Published var sets:String = ""
    @Published var reps:String = ""
    @Published var setNote:String = ""
    @Published var muslceGroup:String = "Chest"
    
    enum InsertionError: Error {
        case invalidReps(String)
        case invalidIndex(String)
    }
    var config: Config
    var context: ModelContext
    
    init(config: Config, context: ModelContext) {
        self.config = config
        self.context = context
    }
    
    @MainActor
    func fetchDay(dayOfSplit: Int?) async -> Day {
        let predicate = #Predicate<Day> {
                $0.dayOfSplit == dayOfSplit!
        }
        let descriptor = FetchDescriptor<Day>(predicate: predicate)
        do {
            let fetchedData: [Day]
            do {
                fetchedData = try context.fetch(descriptor)
                debugPrint("Fetched data: \(fetchedData)")
            } catch {
                debugPrint("Error fetching data: \(error.localizedDescription)")
                return Day(name: "", dayOfSplit: 0, exercises: [],date: "")
            }
            guard !fetchedData.isEmpty else {
                return Day(name: "", dayOfSplit: 0, exercises: [],date: "")
            }
            
            await MainActor.run {
                day = fetchedData.first!
            }
            
            return fetchedData.first!
        }
    }
    
    @MainActor
    func fetchCalendarDay(date: String) async -> Day {
        let predicate = #Predicate<DayStorage> {
                $0.date == date
        }
        let descriptor = FetchDescriptor<DayStorage>(predicate: predicate)
        do {
            let fetchedData: [DayStorage]
            do {
                fetchedData = try context.fetch(descriptor)
                debugPrint("Fetched data: \(fetchedData)")
            } catch {
                debugPrint("Error fetching data: \(error.localizedDescription)")
                return Day(name: "", dayOfSplit: 0, exercises: [],date: "")
            }
            guard !fetchedData.isEmpty else {
                return Day(name: "", dayOfSplit: 0, exercises: [],date: "")
            }
            
            return fetchedData.first!.day
        }
    }
    
    @MainActor
    func fetchAllDays() async -> [Day] {
        let predicate = #Predicate<Day> { _ in true }
        let descriptor = FetchDescriptor<Day>(predicate: predicate)
        do {
            let fetchedData: [Day]
            do {
                fetchedData = try context.fetch(descriptor)
                debugPrint("Fetched data: \(fetchedData)")
            } catch {
                debugPrint("Error fetching data: \(error.localizedDescription)")
                return []
            }
            guard !fetchedData.isEmpty else {
                return []
            }
            
            await MainActor.run {
                day = fetchedData.first!
            }
            
            return fetchedData
        }
    }
    
    func fetchExercise(id: UUID) async -> Exercise {
        let predicate = #Predicate<Exercise> {
            $0.id == id
        }
        let descriptor = FetchDescriptor<Exercise>(predicate: predicate)
        do {
            let fetchedData: [Exercise]
            do {
                fetchedData = try context.fetch(descriptor)
                debugPrint("Fetched data: \(fetchedData)")
            } catch {
                debugPrint("Error fetching data: \(error.localizedDescription)")
                return Exercise(id: UUID(), name: "", sets: [], repGoal: 0, muscleGroup: "")
            }
            guard !fetchedData.isEmpty else {
                return Exercise(id: UUID(), name: "", sets: [], repGoal: 0, muscleGroup: "")
            }
            
            return fetchedData.first!
        }
    }
    
    @MainActor
    func sortDataForCalendar(date: String) async -> [MuscleGroup] {
        var newMuscleGroups: [MuscleGroup] = []
        
        let today = await fetchCalendarDay(date: date)

        for name in muscleGroupNames {
            // Filter exercises for the current muscle group
            let filteredExercises = today.exercises.filter { exercise in
                exercise.muscleGroup == name
            }

            if !filteredExercises.isEmpty {
                // Create a new MuscleGroup and append it
                let group = MuscleGroup(
                    name: name,
                    count: filteredExercises.count,
                    exercises: filteredExercises
                )
                newMuscleGroups.append(group)
            }
        }

        // Return the new array to be reassigned in the view
        return newMuscleGroups
    }
    
    @MainActor
    func sortData(dayOfSplit: Int) async -> [MuscleGroup] {
        var newMuscleGroups: [MuscleGroup] = []
        
        // Fetch current day
        let currentDay = await fetchDay(dayOfSplit: dayOfSplit)
        day = currentDay


        for name in muscleGroupNames {
            // Filter exercises for the current muscle group
            let filteredExercises = day.exercises.filter { exercise in
                exercise.muscleGroup == name
            }

            if !filteredExercises.isEmpty {
                // Create a new MuscleGroup and append it
                let group = MuscleGroup(
                    name: name,
                    count: filteredExercises.count,
                    exercises: filteredExercises
                )
                newMuscleGroups.append(group)
            }
        }

        // Return the new array to be reassigned in the view
        return newMuscleGroups
    }
    
    func deleteItem(set: Exercise.Set, exercise: Exercise) async -> Exercise {
        if let index = exercise.sets.firstIndex(where: { $0.id == set.id }) {
                exercise.sets.remove(at: index)
        }
        context.delete(set)
        do {
            try context.save()
            debugPrint("Deleted set")
        } catch {
            debugPrint(error)
        }
            return await fetchExercise(id : exercise.id)
    }
    
    func addSet(exercise: Exercise) async -> Exercise {
        let currentExercise = await fetchExercise(id: exercise.id)
        currentExercise.sets.insert(
            Exercise.Set.createDefault(),
            at: currentExercise.sets.endIndex
        )
        do {
            try context.save()
        } catch {
            debugPrint(error)
        }
            return await fetchExercise(id : exercise.id)
    }

    @MainActor
    func insertWorkout() async {
        let today = await fetchDay(dayOfSplit: config.dayInSplit)
        debugPrint(day.name)
        context.insert(DayStorage(id: UUID(), day: today, date: formattedDateString(from: Date())))
        config.daysRecorded.insert(formattedDateString(from: Date()), at: 0)
        do {
            try context.save()
            debugPrint("Day saved with date : \(formattedDateString(from: Date()))")
        } catch {
            debugPrint(error)
        }
    }
    
    func formattedDateString(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        return dateFormatter.string(from: date)
    }
    
    func updateDayInSplit() -> Int {
        let calendar = Calendar.current

        // Check if the last update date is today
        if !calendar.isDateInToday(config.lastUpdateDate) {
            let daysPassed = numberOfDaysBetween(start: config.lastUpdateDate, end: Date())
            
            // Calculate the new day in split
            let newDayInSplit = ((config.dayInSplit - 1 + daysPassed) % config.splitLenght) + 1
            
            // Update lastUpdateDate to today
            config.lastUpdateDate = Date()
            config.dayInSplit = newDayInSplit

            return newDayInSplit
        } else {
            return config.dayInSplit
        }
    }

    // Helper function to calculate full days between two dates
    func numberOfDaysBetween(start: Date, end: Date) -> Int {
        let calendar = Calendar.current
        let startOfDayStart = calendar.startOfDay(for: start)
        let startOfDayEnd = calendar.startOfDay(for: end)
        
        let components = calendar.dateComponents([.day], from: startOfDayStart, to: startOfDayEnd)
        return components.day ?? 0
    }
    
    func createExercise() async {
        if !name.isEmpty && !sets.isEmpty && !reps.isEmpty {
            var setList: [Exercise.Set] = []
            for _ in 1...Int(sets)! {
                let set = Exercise.Set(weight: 0, reps: 0, failure: false, time: "", note: "", warmUp: false, restPause: false, dropSet: false, createdAt: Date())
                setList.append(set)
            }
            do {
                
                let today = await fetchDay(dayOfSplit: config.dayInSplit)

                guard let validReps = Int(reps) else {
                    throw InsertionError.invalidReps("Invalid reps value: \(reps)")
                }

                today.exercises.insert(
                    Exercise(
                        id: exerciseId ?? UUID(),
                        name: name,
                        sets: setList,
                        repGoal: validReps,
                        muscleGroup: muslceGroup
                    ),
                    at: day.exercises.endIndex
                )
                debugPrint("Successfully inserted exercise \(name) into \(day.name)")
            } catch {
                debugPrint("Error inserting exercise: \(error.localizedDescription)")
            }
            do {
                try context.save()
                debugPrint("Inserted exercise : \(name)")
            } catch {
                debugPrint(error)
            }
        } else {
            debugPrint("Not all text fields are filled")
        }
    }
}
    
