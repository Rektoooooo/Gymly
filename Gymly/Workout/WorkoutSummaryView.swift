//
//  WorkoutSummaryView.swift
//  Gymly
//
//  Created by Sebastián Kučera and Claude on 16.09.2025.
//

import SwiftUI
import Foundation

struct WorkoutSummaryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var config: Config
    @Environment(\.colorScheme) var scheme

    let completedExercises: [Exercise]
    let workoutDurationMinutes: Int
    let startTime: String
    let endTime: String

    var body: some View {
        NavigationView {
            ZStack {
                FloatingClouds(theme: CloudsTheme.green(scheme))
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 60))

                            Text("Workout Complete!")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Text("Great job on finishing your workout!")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.top, 20)
                        // Workout Duration Card
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(.black)
                                Text("Workout Duration")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                            }

                            HStack {
                                Text("\(workoutDurationMinutes)")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.black)
                                Text("minutes")
                                    .font(.title3)
                                    .foregroundColor(.white.opacity(0.8))
                                Spacer()
                            }

                            HStack {
                                Text("Started: \(startTime)")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                                Spacer()
                                Text("Finished: \(endTime)")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(12)

                        // Workout Stats Cards
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {

                            // Total Exercises
                            VStack {
                                Image(systemName: "dumbbell.fill")
                                    .foregroundColor(.black)
                                    .font(.title2)
                                Text("\(completedExercises.count)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Text("Exercises")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .frame(height: 80)
                            .frame(maxWidth: .infinity)
                            .background(Color.black.opacity(0.2))
                            .cornerRadius(12)

                            // Total Sets
                            VStack {
                                Image(systemName: "list.number")
                                    .foregroundColor(.black)
                                    .font(.title2)
                                Text("\(totalSets)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Text("Sets")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .frame(height: 80)
                            .frame(maxWidth: .infinity)
                            .background(Color.black.opacity(0.2))
                            .cornerRadius(12)

                            // Total Reps
                            VStack {
                                Image(systemName: "repeat")
                                    .foregroundColor(.black)
                                    .font(.title2)
                                Text("\(totalReps)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Text("Reps")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .frame(height: 80)
                            .frame(maxWidth: .infinity)
                            .background(Color.black.opacity(0.2))
                            .cornerRadius(12)

                            // Total Weight
                            VStack {
                                Image(systemName: "scalemass.fill")
                                    .foregroundColor(.black)
                                    .font(.title2)
                                Text("\(formattedTotalWeight)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Text(config.weightUnit)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .frame(height: 80)
                            .frame(maxWidth: .infinity)
                            .background(Color.black.opacity(0.2))
                            .cornerRadius(12)
                        }

                        // Muscle Groups Trained
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "figure.strengthtraining.traditional")
                                    .foregroundColor(.black)
                                Text("Muscle Groups Trained")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                            }

                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 8) {
                                ForEach(uniqueMuscleGroups, id: \.self) { muscleGroup in
                                    Text(muscleGroup)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.black.opacity(0.2))
                                        .foregroundColor(.black)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(12)

                        // Exercises Completed
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "list.bullet")
                                    .foregroundColor(.black)
                                Text("Exercises Completed")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                            }

                            ForEach(completedExercises, id: \.id) { exercise in
                                HStack {
                                    Text(exercise.name)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("\(exercise.sets.count) sets")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(12)

                        Spacer(minLength: 20)
                    }
                    .padding()
                }
            }
            .navigationTitle("Workout Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.black)
                }
            }
        }
    }

    // Computed properties for stats
    private var totalSets: Int {
        completedExercises.reduce(0) { $0 + $1.sets.count }
    }

    private var totalReps: Int {
        completedExercises.reduce(0) { result, exercise in
            result + exercise.sets.reduce(0) { $0 + $1.reps }
        }
    }

    private var totalWeight: Double {
        completedExercises.reduce(0) { result, exercise in
            result + exercise.sets.reduce(0) { $0 + $1.weight }
        }
    }

    private var formattedTotalWeight: String {
        let weightInDisplayUnit = config.weightUnit == "Kg" ? totalWeight : totalWeight * 2.20462
        return String(format: "%.0f", weightInDisplayUnit)
    }

    private var uniqueMuscleGroups: [String] {
        Array(Set(completedExercises.map { $0.muscleGroup })).sorted()
    }
}

#Preview {
    // Create mock exercise sets
    let mockSet1 = Exercise.Set(weight: 80.0, reps: 8, failure: false, warmUp: false, restPause: false, dropSet: false, time: "14:30", note: "Felt strong", createdAt: Date(), bodyWeight: false)
    let mockSet2 = Exercise.Set(weight: 82.5, reps: 6, failure: true, warmUp: false, restPause: false, dropSet: false, time: "14:35", note: "Last rep was tough", createdAt: Date(), bodyWeight: false)
    let mockSet3 = Exercise.Set(weight: 60.0, reps: 12, failure: false, warmUp: false, restPause: true, dropSet: false, time: "14:45", note: "Rest pause set", createdAt: Date(), bodyWeight: false)

    // Create mock exercises
    let benchPress = Exercise(id: UUID(), name: "Bench Press", sets: [mockSet1, mockSet2], repGoal: "8-10", muscleGroup: "Chest", createdAt: Date(), completedAt: Date(), animationId: UUID(), exerciseOrder: 1, done: true, day: nil)
    let inclineDB = Exercise(id: UUID(), name: "Incline Dumbbell Press", sets: [mockSet3], repGoal: "10-12", muscleGroup: "Chest", createdAt: Date(), completedAt: Date(), animationId: UUID(), exerciseOrder: 2, done: true, day: nil)
    let pullups = Exercise(id: UUID(), name: "Pull-ups", sets: [
        Exercise.Set(weight: 0, reps: 10, failure: false, warmUp: false, restPause: false, dropSet: false, time: "15:00", note: "Bodyweight", createdAt: Date(), bodyWeight: true)
    ], repGoal: "8-12", muscleGroup: "Back", createdAt: Date(), completedAt: Date(), animationId: UUID(), exerciseOrder: 3, done: true, day: nil)

    let mockExercises = [benchPress, inclineDB, pullups]

    // Create mock config for weight unit
    let mockConfig = Config(
        weightUnit: "Kg", splitStarted: true, daysRecorded: [], dayInSplit: 1,
        lastUpdateDate: Date(), splitLenght: 7, isUserLoggedIn: true,
        userProfileImageURL: nil, username: "TestUser", userEmail: "test@test.com",
        allowdateOfBirth: false, allowHeight: false, allowWeight: false,
        isHealthEnabled: false, roundSetWeights: false, firstSplitEdit: false,
        activeExercise: 1, graphDataValues: [], graphMaxValue: 1.0,
        graphUpdatedExercisesIDs: Set<UUID>(), userWeight: 80.0, userBMI: 22.0,
        userHeight: 1.80, userAge: 25, totalWorkoutTimeMinutes: 1200
    )

    WorkoutSummaryView(
        completedExercises: mockExercises,
        workoutDurationMinutes: 45,
        startTime: "14:30",
        endTime: "15:15"
    )
    .environmentObject(mockConfig)
}
