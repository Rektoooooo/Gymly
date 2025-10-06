//
//  WorkoutSummarizer.swift
//  Gymly
//
//  Created by Sebastián Kučera on 22.09.2025.
//

import Foundation
import FoundationModels
import SwiftData
import SwiftUI

enum WorkoutSummaryError: LocalizedError {
    case noWorkoutData

    var errorDescription: String? {
        switch self {
        case .noWorkoutData:
            return "No completed workouts found in the selected time period. Complete some workouts and try again."
        }
    }
}

@MainActor
final class WorkoutSummarizer: ObservableObject {
    @Published private(set) var workoutSummary: WorkoutSummary.PartiallyGenerated?
    private var session: LanguageModelSession

    @Published var error: Error?
    @Published var isGenerating = false

    init() {
        self.session = LanguageModelSession(
            instructions: Instructions {
                "You are an expert fitness coach and performance analyst."

                "Your job is to analyze workout data and provide personalized insights."

                "Focus on:"
                "- Identifying patterns in performance"
                "- Recognizing personal records and achievements"
                "- Spotting potential issues with volume, consistency, muscle balance, or training frequency"
                "- Providing actionable recommendations for improvement"

                "Be concise but comprehensive."
                "Use motivating language while being realistic."
                "Always prioritize safety and proper progression."
            }
        )
    }

    func generateWeeklySummary(thisWeek: [CompletedWorkout], lastWeek: [CompletedWorkout]) async throws {
        isGenerating = true
        defer { isGenerating = false }

        // Validate that there is meaningful workout data to analyze
        let hasThisWeekData = !thisWeek.isEmpty && thisWeek.contains { !$0.exercises.isEmpty }
        let hasLastWeekData = !lastWeek.isEmpty && lastWeek.contains { !$0.exercises.isEmpty }

        // If no workout data exists at all, throw an error
        guard hasThisWeekData || hasLastWeekData else {
            throw WorkoutSummaryError.noWorkoutData
        }

        let stream = session.streamResponse(
            generating: WorkoutSummary.self,
            includeSchemaInPrompt: false,
            options: GenerationOptions(sampling: .greedy)
        ) {
            "Analyze the following workout data and generate a comprehensive summary:"

            if hasThisWeekData {
                let workoutNames = thisWeek.map { $0.dayName }.joined(separator: ", ")
                "This week's workout split: \(workoutNames)"

                "THIS WEEK'S WORKOUTS:"
                for (index, workout) in thisWeek.enumerated() {
                "Workout \(index + 1): \(workout.dayName) - \(workout.duration) min"

                for exercise in workout.exercises {
                    let totalVolume = exercise.sets.reduce(0.0) { $0 + ($1.weight * Double($1.reps)) }
                    let maxWeight = exercise.sets.map { $0.weight }.max() ?? 0
                    let totalReps = exercise.sets.reduce(0) { $0 + $1.reps }
                    let specialTechniques = exercise.sets.compactMap { set in
                        if set.failure { return "failure" }
                        if set.dropSet { return "drop" }
                        if set.restPause { return "rest-pause" }
                        return nil
                    }

                    "- \(exercise.name): \(exercise.sets.count) sets, \(totalReps) reps, max \(maxWeight)kg, volume \(String(format: "%.0f", totalVolume))kg"
                    if !specialTechniques.isEmpty {
                        "  (used: \(specialTechniques.joined(separator: ", ")))"
                    }
                }

                    if !workout.incompleteExercises.isEmpty {
                        "Skipped: \(workout.incompleteExercises.map { $0.name }.joined(separator: ", "))"
                    }
                }
            } else {
                "No completed workouts in the current week."
            }

            if hasLastWeekData {
                "LAST WEEK'S SUMMARY (for comparison):"
                "Total workouts: \(lastWeek.count)"
                "Total duration: \(lastWeek.reduce(0) { $0 + $1.duration }) minutes"

                // Calculate essential metrics for comparison
                let lastWeekVolume = lastWeek.flatMap { $0.exercises }.flatMap { $0.sets }.reduce(0.0) { $0 + ($1.weight * Double($1.reps)) }
                let lastWeekTotalSets = lastWeek.flatMap { $0.exercises }.reduce(0) { $0 + $1.sets.count }
                let lastWeekExercises = Set(lastWeek.flatMap { $0.exercises }.map { $0.name })
                let lastWeekSkipped = lastWeek.flatMap { $0.incompleteExercises }.map { $0.name }

                "Total volume: \(String(format: "%.0f", lastWeekVolume)) kg"
                "Total sets: \(lastWeekTotalSets)"
                "Unique exercises: \(lastWeekExercises.count)"
                if !lastWeekSkipped.isEmpty {
                    "Skipped exercises: \(lastWeekSkipped.joined(separator: ", "))"
                }
            } else {
                "No workout data available for comparison from the previous week."
            }

            "Generate a workout summary with:"
            "- A motivating headline capturing the week's key achievement"
            "- A 2-3 sentence overview in plain language"
            if hasThisWeekData && hasLastWeekData {
                "- Key statistics (total volume, sessions, PRs) with percentage changes vs last week (calculate exact percentages like '+15%', '-8%')"
            } else {
                "- Key statistics (total volume, sessions, PRs) - show actual values since no comparison data is available"
            }
            "- Exercise-by-exercise breakdown"
            if hasThisWeekData && hasLastWeekData {
                "- Short-term trends (comparing to previous weeks)"
            } else {
                "- Performance observations from available data"
            }
            "- Personal records achieved"
            "- Any potential training issues (NOT form-related, focus on volume, consistency, balance)"
            "- 2-3 specific, actionable recommendations for next week (prioritize completing skipped exercises if any)"

            if !hasThisWeekData {
                "IMPORTANT: Focus on motivating the user to get back to their workout routine since they haven't completed any workouts this week."
            }

            "Make it personal, specific, and actionable. Do not make up or hallucinate data that wasn't provided."
        }

        for try await partialResponse in stream {
            workoutSummary = partialResponse.content
        }
    }

    func prewarm() {
        session.prewarm()
    }

    func clearSummary() {
        workoutSummary = nil
    }
}

struct CompletedWorkout {
    let date: Date
    let dayName: String
    let duration: Int
    let exercises: [CompletedExercise]
    let incompleteExercises: [IncompleteExercise]
}

struct CompletedExercise {
    let name: String
    let muscleGroup: String
    let sets: [CompletedSet]
}

struct CompletedSet {
    let weight: Double
    let reps: Int
    let failure: Bool
    let dropSet: Bool
    let restPause: Bool
}
