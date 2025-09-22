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

        let stream = session.streamResponse(
            generating: WorkoutSummary.self,
            includeSchemaInPrompt: false,
            options: GenerationOptions(sampling: .greedy)
        ) {
            "Analyze the following workout data and generate a comprehensive summary with percentage comparisons:"

            "THIS WEEK'S WORKOUTS:"
            for (index, workout) in thisWeek.enumerated() {
                "Workout \(index + 1):"
                "Date: \(workout.date)"
                "Day: \(workout.dayName)"
                "Duration: \(workout.duration) minutes"

                for exercise in workout.exercises {
                    "Exercise: \(exercise.name)"
                    "Muscle Group: \(exercise.muscleGroup)"
                    "Sets: \(exercise.sets.count)"

                    for (setIndex, set) in exercise.sets.enumerated() {
                        "Set \(setIndex + 1): \(set.weight)kg × \(set.reps) reps"
                        if set.failure { "(to failure)" }
                        if set.dropSet { "(drop set)" }
                        if set.restPause { "(rest-pause)" }
                    }
                }

                if !workout.incompleteExercises.isEmpty {
                    "Skipped exercises:"
                    for skipped in workout.incompleteExercises {
                        "- \(skipped.name) (\(skipped.muscleGroup))"
                    }
                }
            }

            if !lastWeek.isEmpty {
                "LAST WEEK'S WORKOUTS (for comparison):"
                for (index, workout) in lastWeek.enumerated() {
                    "Workout \(index + 1):"
                    "Date: \(workout.date)"
                    "Day: \(workout.dayName)"
                    "Duration: \(workout.duration) minutes"

                    for exercise in workout.exercises {
                        "Exercise: \(exercise.name)"
                        "Muscle Group: \(exercise.muscleGroup)"
                        "Sets: \(exercise.sets.count)"

                        for (setIndex, set) in exercise.sets.enumerated() {
                            "Set \(setIndex + 1): \(set.weight)kg × \(set.reps) reps"
                            if set.failure { "(to failure)" }
                            if set.dropSet { "(drop set)" }
                            if set.restPause { "(rest-pause)" }
                        }
                    }

                    if !workout.incompleteExercises.isEmpty {
                        "Skipped exercises:"
                        for skipped in workout.incompleteExercises {
                            "- \(skipped.name) (\(skipped.muscleGroup))"
                        }
                    }
                }
            }

            "Generate a workout summary with:"
            "- A motivating headline capturing the week's key achievement"
            "- A 2-3 sentence overview in plain language"
            "- Key statistics (total volume, sessions, PRs) with percentage changes vs last week (calculate exact percentages like '+15%', '-8%', or 'NEW' if no previous data)"
            "- Exercise-by-exercise breakdown"
            "- Short-term trends (comparing to previous weeks if applicable)"
            "- Personal records achieved"
            "- Any potential training issues (NOT form-related, focus on volume, consistency, balance)"
            "- 2-3 specific, actionable recommendations for next week (prioritize completing skipped exercises if any)"

            "Make it personal, specific, and actionable."
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
