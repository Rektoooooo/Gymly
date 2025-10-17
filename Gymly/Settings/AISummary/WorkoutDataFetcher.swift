//
//  WorkoutDataFetcher.swift
//  Gymly
//
//  Created by Sebastián Kučera on 22.09.2025.
//

import Foundation
import SwiftData

@MainActor
class WorkoutDataFetcher {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchWeeklyWorkouts() -> [CompletedWorkout] {
        return fetchWorkouts(weeksBack: 0, numberOfWeeks: 1)
    }

    func fetchWorkoutsForComparison() -> (thisWeek: [CompletedWorkout], lastWeek: [CompletedWorkout]) {
        let thisWeek = fetchWorkouts(weeksBack: 0, numberOfWeeks: 1)
        let lastWeek = fetchWorkouts(weeksBack: 1, numberOfWeeks: 1)
        return (thisWeek, lastWeek)
    }

    private func fetchWorkouts(weeksBack: Int, numberOfWeeks: Int) -> [CompletedWorkout] {
        let calendar = Calendar.current
        let endDate = calendar.date(byAdding: .weekOfYear, value: -weeksBack, to: Date()) ?? Date()
        guard let startDate = calendar.date(byAdding: .day, value: -(numberOfWeeks * 7), to: endDate) else {
            print("🔍 AI Fetch: Failed to create start date")
            return []
        }

        // Use the correct date format that matches your DayStorage entries
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let startDateString = dateFormatter.string(from: startDate)
        let endDateString = dateFormatter.string(from: endDate)

        print("🔍 AI Fetch: Looking for workouts between '\(startDateString)' and '\(endDateString)'")

        // Fetch all DayStorage and filter in-memory since string date comparison is unreliable
        let dayStorageDescriptor = FetchDescriptor<DayStorage>(
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )

        do {
            // Fetch all DayStorage entries
            let allDayStorages = try context.fetch(dayStorageDescriptor)
            print("🔍 AI Fetch: Total DayStorage entries in database: \(allDayStorages.count)")

            // Filter in-memory by converting date strings to Date objects for proper comparison
            let dayStorages = allDayStorages.filter { storage in
                guard let storageDate = dateFormatter.date(from: storage.date) else {
                    print("⚠️ AI Fetch: Could not parse date '\(storage.date)'")
                    return false
                }
                let isInRange = storageDate >= startDate && storageDate <= endDate
                if isInRange {
                    print("✅ AI Fetch: Including \(storage.dayName) on '\(storage.date)'")
                }
                return isInRange
            }

            print("🔍 AI Fetch: Found \(dayStorages.count) DayStorage entries in date range \(startDateString) to \(endDateString)")

            var completedWorkouts: [CompletedWorkout] = []

            for dayStorage in dayStorages {
                print("🔍 AI Fetch: Processing \(dayStorage.dayName) with dayId: \(dayStorage.dayId)")

                // Fetch Day directly by ID (MUCH faster than loading all Days!)
                let dayId = dayStorage.dayId
                let dayDescriptor = FetchDescriptor<Day>(
                    predicate: #Predicate<Day> { day in
                        day.id == dayId
                    }
                )

                guard let day = try context.fetch(dayDescriptor).first else {
                    print("❌ AI Fetch: No Day found with id \(dayId)")
                    continue
                }

                print("🔍 AI Fetch: Found Day: \(day.name)")

                guard let exercises = day.exercises, !exercises.isEmpty else {
                    print("❌ AI Fetch: Day \(day.name) has no exercises")
                    continue
                }

                print("🔍 AI Fetch: Day \(day.name) has \(exercises.count) exercises")

                // Separate completed and incomplete exercises
                let completedExercises = exercises.compactMap { exercise -> CompletedExercise? in
                    print("🔍 AI Fetch: Exercise \(exercise.name) - done: \(exercise.done), sets: \(exercise.sets?.count ?? 0)")

                    guard exercise.done,
                          let sets = exercise.sets,
                          !sets.isEmpty else {
                        return nil
                    }

                    let completedSets = sets.map { set in
                        CompletedSet(
                            weight: set.weight,
                            reps: set.reps,
                            failure: set.failure,
                            dropSet: set.dropSet,
                            restPause: set.restPause
                        )
                    }

                    print("✅ AI Fetch: Exercise \(exercise.name) completed with \(completedSets.count) sets")

                    return CompletedExercise(
                        name: exercise.name,
                        muscleGroup: exercise.muscleGroup,
                        sets: completedSets
                    )
                }

                // Get incomplete exercises for recommendations
                let incompleteExercises = exercises.compactMap { exercise -> IncompleteExercise? in
                    guard !exercise.done else { return nil }

                    print("⚠️ AI Fetch: Exercise \(exercise.name) was skipped")

                    return IncompleteExercise(
                        name: exercise.name,
                        muscleGroup: exercise.muscleGroup
                    )
                }

                guard !completedExercises.isEmpty else {
                    print("❌ AI Fetch: No completed exercises found for \(dayStorage.dayName)")
                    continue
                }

                let workoutDate = dateFormatter.date(from: dayStorage.date) ?? Date()
                let duration = calculateDuration(from: completedExercises)

                completedWorkouts.append(
                    CompletedWorkout(
                        date: workoutDate,
                        dayName: dayStorage.dayName,
                        duration: duration,
                        exercises: completedExercises,
                        incompleteExercises: incompleteExercises
                    )
                )

                print("✅ AI Fetch: Added workout \(dayStorage.dayName) with \(completedExercises.count) exercises")
            }

            print("🔍 AI Fetch: Final result: \(completedWorkouts.count) completed workouts found")
            return completedWorkouts.sorted { $0.date < $1.date }
        } catch {
            print("❌ AI Fetch Error: \(error)")
            return []
        }
    }

    private func calculateDuration(from exercises: [CompletedExercise]) -> Int {
        let totalSets = exercises.reduce(0) { $0 + $1.sets.count }
        let estimatedMinutesPerSet = 3
        let restTimeMinutes = 2
        return (totalSets * estimatedMinutesPerSet) + (totalSets * restTimeMinutes)
    }

    func fetchHistoricalData(for exerciseName: String, weeks: Int = 4) -> [ExerciseHistory] {
        let descriptor = FetchDescriptor<Exercise>(
            predicate: #Predicate<Exercise> { exercise in
                exercise.name == exerciseName && exercise.done == true
            },
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )

        do {
            let exercises = try context.fetch(descriptor)
            return exercises.compactMap { exercise -> ExerciseHistory? in
                guard let sets = exercise.sets, !sets.isEmpty else { return nil }

                let maxWeight = sets.map { $0.weight }.max() ?? 0
                let totalVolume = sets.reduce(0) { $0 + ($1.weight * Double($1.reps)) }

                return ExerciseHistory(
                    date: exercise.completedAt ?? exercise.createdAt,
                    maxWeight: maxWeight,
                    totalVolume: totalVolume,
                    setCount: sets.count
                )
            }
        } catch {
            print("Error fetching historical data: \(error)")
            return []
        }
    }
}

struct ExerciseHistory {
    let date: Date
    let maxWeight: Double
    let totalVolume: Double
    let setCount: Int
}

struct IncompleteExercise {
    let name: String
    let muscleGroup: String
}