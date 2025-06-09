//
//  WorkoutViewModel.swift
//  Gymly
//
//  Created by Sebastián Kučera on 23.10.2024.
//

import Foundation
import SwiftData
import SwiftUI
import AuthenticationServices
import HealthKit

final class WorkoutViewModel: ObservableObject {
    @Published var days: [Day] = []
    @Published var exercises:[Exercise] = []
    @Published var day:Day = Day(name: "", dayOfSplit: 0, exercises: [],date: "")
    @Published var muscleGroups:[MuscleGroup] = []
    @Published var editPlan:Bool = false
    @Published var addExercise:Bool = false
    @Published var exerciseAddedTrigger = false
    @Published var muscleGroupNames:[String] = ["Chest","Back","Biceps","Triceps","Shoulders","Quads","Hamstrings","Calves","Glutes","Abs"]
    @Published var exerciseId: UUID? = nil
    @Published var name:String = ""
    @Published var sets:String = ""
    @Published var reps:String = ""
    @Published var setNote:String = ""
    @Published var muscleGroup:String = "Chest"
    @Published var emptyDay: Day = Day(name: "", dayOfSplit: 0, exercises: [], date: "")
    @Published var activeExercise: Int = 1
    enum MuscleGroupEnum: String, CaseIterable, Identifiable {
        case chest, back, biceps, triceps, shoulders, quads, hamstrings, calves, glutes, abs
        
        var id: String { self.rawValue }
    }
    
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
    
    // MARK: Split related funcs
    /// Create new split
    @MainActor
    func createNewSplit(name: String, numberOfDays: Int, startDate: Date, context: ModelContext) {
        var days: [Day] = []
        
        for i in 1...numberOfDays {
            let day = Day(name: "Day \(i)", dayOfSplit: i, exercises: [], date: "")
            days.append(day)
        }
        
        

        let newSplit = Split(name: name, days: days, isActive: true, startDate: startDate)
        context.insert(newSplit)
        switchActiveSplit(split: newSplit, context: context)

        do {
            try context.save()
            print("New split '\(name)' created.")
        } catch {
            print("Error saving split: \(error)")
        }
    }
    
    /// Fetch active split
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
    
    /// Fetch all days for active split
    @MainActor
    func getActiveSplitDays() -> [Day] {
        guard let activeSplit = getActiveSplit() else {
            print("No active split found.")
            return []   
        }
        return activeSplit.days
    }

    /// Set all splits as inactive
    @MainActor
    func deactivateAllSplits() {
        Task { @MainActor in
            do {
                let splits = getAllSplits()
                for split in splits {
                    split.isActive = false
                }
                try context.save()
                objectWillChange.send() // Force UI to refresh
            } catch {
                print("Error deactivating splits: \(error)")
            }
        }
    }
    
    /// Switch split from inactive to active
    @MainActor
    func switchActiveSplit(split: Split, context: ModelContext) {
        deactivateAllSplits()
        
        Task { @MainActor in
            split.isActive = true
            do {
                try context.save()
                print("Switched to active split: \(split.name)")
                objectWillChange.send() // Manually notify SwiftUI of changes
            } catch {
                print("Error switching split: \(error)")
            }
        }
    }
    
    /// Fetch all splits
    @MainActor
    func getAllSplits() -> [Split] {
        let predicate = #Predicate<Split> { _ in true }
        let fetchDescriptor = FetchDescriptor<Split>(predicate: predicate)
        return try! context.fetch(fetchDescriptor)
    }
    
    /// Delete split
    @MainActor
    func deleteSplit(split: Split) {
        context.delete(split)
        do {
            try context.save()
            debugPrint("Deleted split: \(split.name)")
        } catch {
            debugPrint(error)
        }
    }
    
    // MARK: Day related funcs
    
    /// Fetch day with dayOfSplit as input
    @MainActor
    func fetchDay(dayOfSplit: Int?) async -> Day {
        let activeSplitDays = getActiveSplitDays().filter { $0.dayOfSplit == dayOfSplit }
        
        if let existingDay = activeSplitDays.first {
            debugPrint("Returning existing day: \(existingDay.name)")
            return existingDay
        } else {
            debugPrint("No existing day found, creating new one.")

            let newDay = Day(name: "", dayOfSplit: 0, exercises: [], date: "")
            
            context.insert(newDay)
            try? context.save()

            return newDay
        }
    }
    
    /// Fetch day based on date
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

    /// Sort exercises to there respective muscle group from date
    @MainActor
    func sortDataForCalendar(date: String) async -> [MuscleGroup] {
        var newMuscleGroups: [MuscleGroup] = []
        
        let today = await fetchCalendarDay(date: date)

        for name in muscleGroupNames {
            let filteredExercises = today.exercises.filter { exercise in
                exercise.muscleGroup == name
            }

            if !filteredExercises.isEmpty {
                let group = MuscleGroup(
                    name: name,
                    exercises: filteredExercises
                )
                newMuscleGroups.append(group)
            }
        }

        return newMuscleGroups
    }
    
    /// Sort exercises to there respective muscle group from dayOfSplit
    @MainActor
    func sortData(dayOfSplit: Int) async -> [MuscleGroup] {
        var newMuscleGroups: [MuscleGroup] = []
        
        let updatedDay = await fetchDay(dayOfSplit: dayOfSplit)
        debugPrint("Exercises fetch for day : \(updatedDay.exercises.count)")

        let freshExercises = updatedDay.exercises

        await MainActor.run {
            self.day = updatedDay
        }

        for name in muscleGroupNames {
            let filteredExercises = freshExercises.filter { $0.muscleGroup == name }
            if !filteredExercises.isEmpty {
                let group = MuscleGroup(
                    name: name,
                    exercises: filteredExercises.sorted { $0.createdAt < $1.createdAt }
                )
                newMuscleGroups.append(group)
            }
        }
        
        return newMuscleGroups
    }
    
    /// Helper function for creating days when creating split
    func addDay(name: String, index: Int) {
        debugPrint("Attempting to add: \(name) with index \(index)")
        
        if days.contains(where: { $0.dayOfSplit == index }) {
            debugPrint("Skipping duplicate day: \(name)")
            return
        }
        context.insert(Day(name: name, dayOfSplit: index, exercises: [], date: ""))
        debugPrint("Added day: \(name)")
    }

    /// Insert day into **DayStorage** and display it in calendar
    @MainActor
    func insertWorkout() async {
        let today = await fetchDay(dayOfSplit: config.dayInSplit)
        
        let newDay = Day(
            name: today.name,
            dayOfSplit: today.dayOfSplit,
            exercises: today.exercises.filter { $0.done }.map { $0.copy() },
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
    
    @MainActor
    func copyWorkout(from: Day, to: Day) {
        to.exercises.removeAll()
        to.exercises = from.exercises.map { $0.copy() }
    }
    
 // MARK: Calendar oriented functions
    
    /// Get time for comparing
    func formattedDateString(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        return dateFormatter.string(from: date)
    }
    
    /// Get year and moth for calnedar day titile
    func monthAndYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    /// Get how many days ar ein a month for calendar
    func getDaysInMonth(for date: Date) -> [DayCalendar] {
        guard let range = Calendar.current.range(of: .day, in: .month, for: date),
              let firstDayOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: date)) else {
            return []
        }
        let firstWeekday = Calendar.current.component(.weekday, from: firstDayOfMonth)
        var days: [DayCalendar] = []

        let offset = (firstWeekday + 5) % 7
        days.append(contentsOf: Array(repeating: DayCalendar(day: 0, date: Date()), count: offset))

        days.append(contentsOf: range.compactMap { day -> DayCalendar? in
            if let date = Calendar.current.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                return DayCalendar(day: day, date: date)
            }
            return nil
        })

        return days
    }
    
    // MARK: Functions for keeping app to date
    
    /// Update day in split based on how many days user  dident open the app
    @MainActor func updateDayInSplit() -> Int {
        let calendar = Calendar.current

        if !calendar.isDateInToday(config.lastUpdateDate) {
            let daysPassed = numberOfDaysBetween(start: config.lastUpdateDate, end: Date())

            let totalDays = config.dayInSplit + daysPassed
            
            let activeSplit = getActiveSplit()
            
            let newDayInSplit = (totalDays - 1) % activeSplit!.days.count + 1

            config.dayInSplit = newDayInSplit
            config.lastUpdateDate = Date()
            config.activeExercise = 1
            
            return config.dayInSplit
        } else {
            return config.dayInSplit
        }
    }
    
    /// Get number of days from last time user opened app
    func numberOfDaysBetween(start: Date, end: Date) -> Int {
        let calendar = Calendar.current
        let startOfDayStart = calendar.startOfDay(for: start)
        let startOfDayEnd = calendar.startOfDay(for: end)
        debugPrint(startOfDayStart)
        debugPrint(startOfDayEnd)
        let components = calendar.dateComponents([.day], from: startOfDayStart, to: startOfDayEnd)
        return components.day ?? 0
    }
    
    // MARK: Functions for exercise
    
    /// Create new exercises and add it to respective day
    func createExercise(to: Day) async {
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
                let today = await fetchDay(dayOfSplit: config.dayInSplit)

                if today.exercises.contains(where: { $0.name == name }) {
                    debugPrint("Exercise already exists in today's workout.")
                    return
                }

                
                let newExercise = Exercise(
                    id: UUID(),
                    name: name,
                    sets: setList,
                    repGoal: reps,
                    muscleGroup: muscleGroup,
                    createdAt: Date(),
                    exerciseOrder: await fetchDay(dayOfSplit: config.dayInSplit).exercises.count + 1, done: false
                )

                await MainActor.run {
                    to.exercises.append(newExercise)
                    try? context.save()
                }

                debugPrint("Successfully added exercise \(name) to \(today.name)")
                
                /// Notify UI to refresh
                await MainActor.run {
                    self.exerciseAddedTrigger.toggle()
                }
                
            }
        } else {
            debugPrint("Not all text fields are filled")
        }
    }
    /// Delete exercise for day
    func deleteExercise(_ exercise: Exercise) {
        guard let day = exercise.day else {
            debugPrint("Exercise has no associated day.")
            return
        }
        day.exercises.removeAll { $0.id == exercise.id }
        context.delete(exercise)
        do {
            try context.save()
            debugPrint("Deleted exercise: \(exercise.name)")
        } catch {
            debugPrint(error)
        }
    }
    
    
    /// Fetch exercise from id
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
                return Exercise(id: UUID(), name: "", sets: [], repGoal: "", muscleGroup: "", exerciseOrder: 0)
            }
            guard !fetchedData.isEmpty else {
                return Exercise(id: UUID(), name: "", sets: [], repGoal: "", muscleGroup: "", exerciseOrder: 0)
            }
            
            return fetchedData.first!
        }
    }
    
    /// Fetch exercises for day
    func fetchAllExerciseForDay(day: Day) async -> [Exercise] {
        let descriptor = FetchDescriptor<Exercise>()
        do {
            let fetchedData: [Exercise]
            do {
                fetchedData = try context.fetch(descriptor)
                debugPrint("Fetched exercises: \(fetchedData.count)")
            } catch {
                debugPrint("Error fetching data: \(error.localizedDescription)")
                return []
            }
            guard !fetchedData.isEmpty else {
                return []
            }
            return fetchedData
        }
    }
    
    // MARK: Functions for sets
    
    /// Delete set for exercise
    func deleteSet(_ set: Exercise.Set, exercise: Exercise) {
        if let index = exercise.sets.firstIndex(where: { $0.id == set.id }) {
            withAnimation {
                _ = exercise.sets.remove(at: index)
            }
        }
        context.delete(set)
    }
    /// Add set for exercise
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
    
    // MARK: Functions for loading profile image
    
    /// Get url for image
    func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    /// Load image from path
    func loadImage(from path: String) -> UIImage? {
        let fileURL = URL(fileURLWithPath: path)
        guard FileManager.default.fileExists(atPath: fileURL.path),
              let imageData = try? Data(contentsOf: fileURL),
              let uiImage = UIImage(data: imageData) else {
            return nil
        }
        return uiImage
    }
    
    /// Saves the UIImage to the Documents directory
    func saveImageToDocuments(image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        
        let filename = "profile_picture.jpg"
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
        
        do {
            try data.write(to: fileURL)
            return fileURL.path
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
    
    // MARK: Authentication funcs
    
    private func handleSuccessfulLogin(with authorization: ASAuthorization) {
        if let userCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            print(userCredential.user)
            
            if userCredential.authorizedScopes.contains(.fullName) {
                print(userCredential.fullName?.givenName ?? "No given name")
            }
            
            if userCredential.authorizedScopes.contains(.email) {
                print(userCredential.email ?? "No email")
            }
        }
    }
    
    private func handleLoginError(with error: Error) {
        print("Could not authenticate: \\(error.localizedDescription)")
    }
    
    // MARK: Import export SPLIT functions
    func importSplit(from url: URL) -> Split? {
        guard url.startAccessingSecurityScopedResource() else {
            print("❌ Could not access security scoped resource.")
            return nil
        }
        defer { url.stopAccessingSecurityScopedResource() }

        do {
            guard FileManager.default.fileExists(atPath: url.path) else {
                print("❌ File not found at: \(url.path)")
                return nil
            }

            print("📂 Importing file from: \(url.path)")
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let decodedSplit = try decoder.decode(Split.self, from: data)

            let newSplit = Split(
                id: UUID(),
                name: decodedSplit.name,
                days: [],
                isActive: decodedSplit.isActive,
                startDate: decodedSplit.startDate
            )

            for decodedDay in decodedSplit.days {
                let newDay = Day(
                    id: UUID(),
                    name: decodedDay.name,
                    dayOfSplit: decodedDay.dayOfSplit,
                    exercises: [],
                    date: decodedDay.date
                )

                for decodedExercise in decodedDay.exercises {
                    let newExercise = Exercise(
                        id: UUID(),
                        name: decodedExercise.name,
                        sets: decodedExercise.sets,
                        repGoal: decodedExercise.repGoal,
                        muscleGroup: decodedExercise.muscleGroup,
                        createdAt: decodedExercise.createdAt,
                        exerciseOrder: decodedExercise.exerciseOrder
                    )
                    newDay.exercises.append(newExercise)
                }

                newSplit.days.append(newDay)
            }

            context.insert(newSplit)
            try context.save()
            print("✅ Split successfully saved: \(newSplit.name)")

            return newSplit

        } catch {
            print("❌ Error importing split: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Export split
    func exportSplit(_ split: Split) -> URL? {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(split)

            // Save to the Documents directory
            let fileManager = FileManager.default
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsURL.appendingPathComponent("\(split.name).gymlysplit")

            try data.write(to: fileURL, options: .atomic) // Ensure file is properly saved
            return fileURL
        } catch {
            print("Error exporting split: \(error)")
            return nil
        }
    }
    
    // MARK: Update mmuscle group for chart
    @MainActor
    func updateMuscleGroupDataValues(from exercises: [Exercise]) {
        var muscleCounts: [MuscleGroupEnum: Double] = [:]

        // Start from existing values
        for (index, group) in MuscleGroupEnum.allCases.enumerated() {
            muscleCounts[group] = config.graphDataValues.indices.contains(index)
                ? config.graphDataValues[index]
                : 0.0
        }

        // Filter out already-used exercises
        let newExercises = exercises.filter { !config.graphUpdatedExerciseIDs.contains($0.id) }

        // Add new exercise contributions
        for exercise in newExercises {
            if let group = MuscleGroupEnum(rawValue: exercise.muscleGroup.lowercased()) {
                muscleCounts[group, default: 0] += Double(exercise.sets.count)
            }
        }

        let orderedGroups = MuscleGroupEnum.allCases

        let computedMax = muscleCounts.values.max() ?? 1.0
        let safeMax = max(computedMax, 1.0)
        let dynamicMin = max(1.0, safeMax * 0.2)

        let rawValues = orderedGroups.map { max(dynamicMin, muscleCounts[$0] ?? 0) }

        config.graphDataValues = rawValues
        config.graphMaxValue = safeMax

        // Record these exercise IDs as "used"
        config.graphUpdatedExerciseIDs.formUnion(newExercises.map { $0.id })

        debugPrint("Updated graphDataValues: \(rawValues)")
    }

}
    
