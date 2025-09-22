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
        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -7, to: endDate) else {
            print("🔍 AI Fetch: Failed to create start date")
            return []
        }

        // Use the correct date format that matches your DayStorage entries
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        let startDateString = dateFormatter.string(from: startDate)
        let endDateString = dateFormatter.string(from: endDate)

        print("🔍 AI Fetch: Looking for workouts between '\(startDateString)' and '\(endDateString)'")

        // Use DayStorage approach since it's more reliable
        let dayStorageDescriptor = FetchDescriptor<DayStorage>(
            predicate: #Predicate<DayStorage> { dayStorage in
                dayStorage.date >= startDateString && dayStorage.date <= endDateString
            },
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )

        do {
            // First, let's see ALL DayStorage entries to understand the data
            let allDayStorageDescriptor = FetchDescriptor<DayStorage>(
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            let allDayStorages = try context.fetch(allDayStorageDescriptor)
            print("🔍 AI Fetch: Total DayStorage entries in database: \(allDayStorages.count)")

            for (index, storage) in allDayStorages.prefix(10).enumerated() {
                print("🔍 AI Fetch: DayStorage \(index + 1): \(storage.dayName) on '\(storage.date)'")
            }

            let dayStorages = try context.fetch(dayStorageDescriptor)
            print("🔍 AI Fetch: Found \(dayStorages.count) DayStorage entries in date range \(startDateString) to \(endDateString)")

            for (index, storage) in dayStorages.enumerated() {
                print("🔍 AI Fetch: DayStorage \(index + 1): \(storage.dayName) on \(storage.date)")
            }

            var completedWorkouts: [CompletedWorkout] = []

            for dayStorage in dayStorages {
                print("🔍 AI Fetch: Processing \(dayStorage.dayName) with dayId: \(dayStorage.dayId)")

                // Fetch all days that match this dayId
                let allDaysDescriptor = FetchDescriptor<Day>()
                let allDays = try context.fetch(allDaysDescriptor)
                print("🔍 AI Fetch: Found \(allDays.count) total Days in database")

                guard let day = allDays.first(where: { $0.id == dayStorage.dayId }) else {
                    print("❌ AI Fetch: No Day found with id \(dayStorage.dayId)")
                    continue
                }

                print("🔍 AI Fetch: Found Day: \(day.name)")

                guard let exercises = day.exercises, !exercises.isEmpty else {
                    print("❌ AI Fetch: Day \(day.name) has no exercises")
                    continue
                }

                print("🔍 AI Fetch: Day \(day.name) has \(exercises.count) exercises")

                let completedExercises = exercises.compactMap { exercise -> CompletedExercise? in
                    print("🔍 AI Fetch: Exercise \(exercise.name) - done: \(exercise.done), sets: \(exercise.sets?.count ?? 0)")

                    guard exercise.done,
                          let sets = exercise.sets,
                          !sets.isEmpty else {
                        print("❌ AI Fetch: Exercise \(exercise.name) not completed or has no sets")
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
                        exercises: completedExercises
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
        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .weekOfYear, value: -weeks, to: endDate) else {
            return []
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startDateString = dateFormatter.string(from: startDate)

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