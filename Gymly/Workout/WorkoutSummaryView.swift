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
    @EnvironmentObject var userProfileManager: UserProfileManager

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
                                    .foregroundColor(.white)
                                Text("Workout Duration")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                            }

                            HStack {
                                Text("\(workoutDurationMinutes)")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.white)
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
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)

                        // Workout Stats Cards
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {

                            // Total Exercises
                            VStack {
                                Image(systemName: "dumbbell.fill")
                                    .foregroundColor(.white)
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
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)

                            // Total Sets
                            VStack {
                                Image(systemName: "list.number")
                                    .foregroundColor(.white)
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
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)

                            // Total Reps
                            VStack {
                                Image(systemName: "repeat")
                                    .foregroundColor(.white)
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
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)

                            // Total Weight
                            VStack {
                                Image(systemName: "scalemass.fill")
                                    .foregroundColor(.white)
                                    .font(.title2)
                                Text("\(formattedTotalWeight)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Text(userProfileManager.currentProfile?.weightUnit ?? "Kg")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .frame(height: 80)
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)
                        }

                        // Muscle Groups Trained
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "figure.strengthtraining.traditional")
                                    .foregroundColor(.white)
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
                                        .background(Color.white.opacity(0.2))
                                        .foregroundColor(.white)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)

                        // Exercises Completed
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "list.bullet")
                                    .foregroundColor(.white)
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
                                    Text("\(exercise.sets?.count ?? 0) sets")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
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
                    .bold()
                }
            }
        }
    }

    // Computed properties for stats
    private var totalSets: Int {
        completedExercises.reduce(0) { $0 + ($1.sets?.count ?? 0) }
    }

    private var totalReps: Int {
        completedExercises.reduce(0) { result, exercise in
            result + (exercise.sets ?? []).reduce(0) { $0 + $1.reps }
        }
    }

    private var totalWeight: Double {
        completedExercises.reduce(0) { result, exercise in
            result + (exercise.sets ?? []).reduce(0) { $0 + $1.weight }
        }
    }

    private var formattedTotalWeight: String {
        let weightInDisplayUnit = userProfileManager.currentProfile?.weightUnit ?? "Kg" == "Kg" ? totalWeight : totalWeight * 2.20462
        return String(format: "%.0f", weightInDisplayUnit)
    }

    private var uniqueMuscleGroups: [String] {
        Array(Set(completedExercises.map { $0.muscleGroup })).sorted()
    }
}

