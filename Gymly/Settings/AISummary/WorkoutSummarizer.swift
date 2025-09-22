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
                "- Spotting potential issues with form, volume, or consistency"
                "- Providing actionable recommendations for improvement"

                "Be concise but comprehensive."
                "Use motivating language while being realistic."
                "Always prioritize safety and proper progression."
            }
        )
    }

    func generateWeeklySummary(from workouts: [CompletedWorkout]) async throws {
        isGenerating = true
        defer { isGenerating = false }

        let stream = session.streamResponse(
            generating: WorkoutSummary.self,
            includeSchemaInPrompt: false,
            options: GenerationOptions(sampling: .greedy)
        ) {
            "Analyze the following workout data from the past week and generate a comprehensive summary:"

            for (index, workout) in workouts.enumerated() {
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
            }

            "Generate a workout summary with:"
            "- A motivating headline capturing the week's key achievement"
            "- A 2-3 sentence overview in plain language"
            "- Key statistics (total volume, sessions, PRs)"
            "- Exercise-by-exercise breakdown"
            "- Short-term trends (comparing to previous weeks if applicable)"
            "- Personal records achieved"
            "- Any potential issues to address"
            "- 2-3 specific, actionable recommendations for next week"

            "Make it personal, specific, and actionable."
        }

        for try await partialResponse in stream {
            workoutSummary = partialResponse.content
        }
    }

    func prewarm() {
        session.prewarm()
    }
}

struct CompletedWorkout {
    let date: Date
    let dayName: String
    let duration: Int
    let exercises: [CompletedExercise]
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