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
    @Published var exerciseAddedTrigger = false // ✅ Add this to trigger a UI update
    @Published var muscleGroupNames:[String] = ["Chest","Back","Biceps","Triceps","Shoulders","Legs","Abs"]
    @Published var exerciseId: UUID? = nil
    @Published var name:String = ""
    @Published var sets:String = ""
    @Published var reps:String = ""
    @Published var setNote:String = ""
    @Published var muscleGroup:String = "Chest"
    @Published var emptyDay: Day = Day(name: "", dayOfSplit: 0, exercises: [], date: "")
    
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
    func createNewSplit(name: String, numberOfDays: Int, startDate: Date, context: ModelContext) {
        var days: [Day] = []
        
        for i in 1...numberOfDays {
            let day = Day(name: "Day \(i)", dayOfSplit: i, exercises: [], date: "")
            days.append(day)
        }
        
        deactivateAllSplits(context: context) // ✅ Ensure only ONE split is active

        let newSplit = Split(name: name, days: days, isActive: true, startDate: startDate)
        context.insert(newSplit)

        do {
            try context.save()
            print("New split '\(name)' created.")
        } catch {
            print("Error saving split: \(error)")
        }
    }
    
    @MainActor
    func getActiveSplit() -> Split? {
        let fetchDescriptor = FetchDescriptor<Split>(predicate: #Predicate { $0.isActive })
        do {
            return try context.fetch(fetchDescriptor).first
        } catch {
            print("Error fetching active split: \(error)")
            return nil
        }
    }
    
    @MainActor
    func getActiveSplitDays() -> [Day] {
        guard let activeSplit = getActiveSplit() else {
            print("No active split found.")
            return []
        }
        return activeSplit.days
    }

    @MainActor
    func deactivateAllSplits(context: ModelContext) {
        let fetchDescriptor = FetchDescriptor<Split>()

        do {
            let splits = try context.fetch(fetchDescriptor)
            for split in splits {
                split.isActive = false // ✅ Set all splits to inactive
            }
            try context.save() // ✅ Save the changes
        } catch {
            print("Error deactivating splits: \(error)")
        }
    }
    
    @MainActor
    func getAllSplits(context: ModelContext) -> [Split] {
        let predicate = #Predicate<Split> { _ in true }
        let fetchDescriptor = FetchDescriptor<Split>(predicate: predicate)
        return try! context.fetch(fetchDescriptor)
    }
    
    @MainActor
    func switchActiveSplit(split: Split, context: ModelContext) {
        deactivateAllSplits(context: context) // ✅ Deactivate all others
        split.isActive = true // ✅ Activate selected split

        do {
            try context.save()
            print("Switched to active split: \(split.name)")
        } catch {
            print("Error switching split: \(error)")
        }
    }
    
    @MainActor
    func fetchDay(dayOfSplit: Int?) async -> Day {
        let activeSplitDays = getActiveSplitDays().filter { $0.dayOfSplit == dayOfSplit }
        
        if let existingDay = activeSplitDays.first {
            debugPrint("Returning existing day: \(existingDay.name)")
            return existingDay  // ✅ Return the already managed object
        } else {
            debugPrint("No existing day found, creating new one.")

            // ✅ Create a new `Day` and save it immediately to SwiftData
            let newDay = Day(name: "", dayOfSplit: 0, exercises: [], date: "")
            
            context.insert(newDay)  // ✅ Insert into SwiftData
            try? context.save()  // ✅ Save immediately

            return newDay  // ✅ Now the returned object is properly managed
        }
    }
    
    @MainActor
    func fetchCalendarDay(date: String) async -> Day {
        let predicate = #Predicate<DayStorage> {
            $0.date == date
        }
        let descriptor = FetchDescriptor<DayStorage>(predicate: predicate)

        do {
            let fetchedData = try context.fetch(descriptor)
            debugPrint("Fetched calendar day count: \(fetchedData.count)")

            guard let dayStorage = fetchedData.first else {
                return emptyDay
            }

            return dayStorage.day // Correctly return the saved day instance!

        } catch {
            debugPrint("Error fetching data: \(error.localizedDescription)")
            return emptyDay
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
                debugPrint("Fetched exercises: \(fetchedData.count)")
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
        
        // ✅ Ensure a fresh fetch of the current day
        let updatedDay = await fetchDay(dayOfSplit: dayOfSplit)

        // ✅ Force a SwiftData re-fetch by accessing `updatedDay.exercises`
        let freshExercises = updatedDay.exercises

        await MainActor.run {
            self.day = updatedDay // ✅ Replace the `day` reference
        }

        for name in muscleGroupNames {
            // ✅ Filter the freshly fetched exercises
            let filteredExercises = freshExercises.filter { $0.muscleGroup == name }

            if !filteredExercises.isEmpty {
                let group = MuscleGroup(
                    name: name,
                    count: filteredExercises.count,
                    exercises: filteredExercises.sorted { $0.createdAt < $1.createdAt }
                )
                newMuscleGroups.append(group)
            }
        }
        
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
    
    func addDay(name: String, index: Int) {
        debugPrint("Attempting to add: \(name) with index \(index)")
        
        if days.contains(where: { $0.dayOfSplit == index }) {
            debugPrint("Skipping duplicate day: \(name)")
            return
        }
        
        context.insert(Day(name: name, dayOfSplit: index, exercises: [], date: ""))
        debugPrint("Added day: \(name)")
    }

    @MainActor
    func insertWorkout() async {
        let today = await fetchDay(dayOfSplit: config.dayInSplit)
        
        // Create a new deep copy of the day and its exercises
        let newDay = Day(
            name: today.name,
            dayOfSplit: today.dayOfSplit, exercises: today.exercises.map { $0.copy() },
            date: formattedDateString(from: Date())
        )
        

        let dayStorage = DayStorage(id: UUID(), day: newDay, date: formattedDateString(from: Date()))
        context.insert(dayStorage)
        config.daysRecorded.insert(formattedDateString(from: Date()), at: 0)
        
        do {
            try context.save()
            debugPrint("Day saved with date: \(formattedDateString(from: Date()))")
        } catch {
            debugPrint(error)
        }
    }
    
    
    func formattedDateString(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        return dateFormatter.string(from: date)
    }
    
    @MainActor func updateDayInSplit() -> Int {
        let calendar = Calendar.current

        if !calendar.isDateInToday(config.lastUpdateDate) {
            let daysPassed = numberOfDaysBetween(start: config.lastUpdateDate, end: Date())

            let totalDays = config.dayInSplit + daysPassed // ✅ No need to subtract 1
            
            let activeSplit = getActiveSplit()
            
            let newDayInSplit = (totalDays - 1) % activeSplit!.days.count + 1 // ✅ Ensures range [1, splitLength]

            config.dayInSplit = newDayInSplit
            config.lastUpdateDate = Date() // ✅ Update the last checked date

            return config.dayInSplit
        } else {
            return config.dayInSplit
        }
    }
    // Helper function to calculate full days between two dates
    func numberOfDaysBetween(start: Date, end: Date) -> Int {
        let calendar = Calendar.current
        let startOfDayStart = calendar.startOfDay(for: start)
        let startOfDayEnd = calendar.startOfDay(for: end)
        debugPrint(startOfDayStart)
        debugPrint(startOfDayEnd)
        let components = calendar.dateComponents([.day], from: startOfDayStart, to: startOfDayEnd)
        return components.day ?? 0
    }
    
    func createExercise() async {
        if !name.isEmpty && !sets.isEmpty && !reps.isEmpty {
            var setList: [Exercise.Set] = []
            
            guard let numSets = Int(sets) else {
                debugPrint("Invalid sets value: \(sets)")
                return
            }

            for _ in 1...numSets {
                let set = Exercise.Set.createDefault()
                setList.append(set)
            }

            do {
                // ✅ Fetch a properly saved `Day`
                let today = await fetchDay(dayOfSplit: config.dayInSplit)

                guard let validReps = Int(reps) else {
                    throw InsertionError.invalidReps("Invalid reps value: \(reps)")
                }

                // ✅ Ensure no duplicates
                if today.exercises.contains(where: { $0.name == name }) {
                    debugPrint("Exercise already exists in today's workout.")
                    return
                }

                // ✅ Create a new exercise
                let newExercise = Exercise(
                    id: UUID(),
                    name: name,
                    sets: setList,
                    repGoal: validReps,
                    muscleGroup: muscleGroup,
                    createdAt: Date()
                )

                // ✅ Ensure SwiftData registers the new exercise
                await MainActor.run {
                    today.exercises.append(newExercise)  // ✅ Add safely
                    try? context.save()  // ✅ Save the update
                }

                debugPrint("Successfully added exercise \(name) to \(today.name)")
                
                // ✅ Notify UI to refresh
                await MainActor.run {
                    self.exerciseAddedTrigger.toggle()
                }
                
            } catch {
                debugPrint("Error inserting exercise: \(error.localizedDescription)")
            }
        } else {
            debugPrint("Not all text fields are filled")
        }
    }
    
    
    func loadImageFromDocuments(filename: String) -> UIImage? {
        let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
        if let imageData = try? Data(contentsOf: fileURL) {
            return UIImage(data: imageData)
        }
        return nil
    }
    
    func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func loadImage(from path: String) -> UIImage? {
        let fileURL = URL(fileURLWithPath: path)
        guard FileManager.default.fileExists(atPath: fileURL.path),
              let imageData = try? Data(contentsOf: fileURL),
              let uiImage = UIImage(data: imageData) else {
            return nil
        }
        return uiImage
    }
}
    
