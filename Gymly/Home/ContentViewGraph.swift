//
//  ContentViewGraph.swift
//  Gymly
//
//  Created by Sebastián Kučera on 24.09.2024.
//

import SwiftUI
import SwiftData

struct ContentViewGraph: View {
    @EnvironmentObject var config: Config
    @Environment(\.modelContext) private var modelContext
    var range: TimeRange
    @State private var chartValues: [Double] = []
    @State private var chartMax: Double = 1.0

    enum TimeRange: String, CaseIterable, Identifiable {
        case day = "Day"
        case week = "Week"
        case month = "Month"
        case all = "All"
        var id: String { rawValue }
    }

    // Define muscle groups in the same order as your radar chart
    private let muscleGroups = ["chest", "back", "biceps", "triceps", "shoulders", "quads", "hamstrings", "calves", "glutes", "abs"]

    private var cal: Calendar { Calendar.current }
    private func startOfDay(_ d: Date) -> Date { cal.startOfDay(for: d) }
    private func startOfWeek(_ d: Date) -> Date { cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: d)) ?? startOfDay(d) }
    private func startOfMonth(_ d: Date) -> Date { cal.date(from: cal.dateComponents([.year, .month], from: d)) ?? startOfDay(d) }

    private func calculateMuscleGroupData() {
        debugPrint("[Graph] Calculating muscle group data for range: \(range)")

        // Determine the date range to filter - backward looking periods
        let now = Date()
        let fromDate: Date?

        switch range {
        case .day:
            // Today only - from start of today to now
            fromDate = startOfDay(now)
        case .week:
            // Past 7 days - from 7 days ago to now
            fromDate = cal.date(byAdding: .day, value: -7, to: now)
        case .month:
            // Past 30 days - from 30 days ago to now
            fromDate = cal.date(byAdding: .day, value: -30, to: now)
        case .all:
            // All time - no date filtering
            fromDate = nil
        }

        debugPrint("[Graph] Filtering from date: \(fromDate?.description ?? "all time") to now")

        do {
            // Fetch all exercises directly from the database
            let allExercises = try modelContext.fetch(FetchDescriptor<Exercise>(sortBy: [SortDescriptor(\.createdAt)]))
            debugPrint("[Graph] Found \(allExercises.count) total exercises in database")

            // Filter exercises based on the time range and completion status
            let filteredExercises = allExercises.filter { exercise in
                // Only count completed exercises that have a completion date
                guard exercise.done, let completedAt = exercise.completedAt else { return false }

                // Apply time filter based on completion date
                if let fromDate = fromDate {
                    return completedAt >= fromDate
                } else {
                    return true // All time
                }
            }

            debugPrint("[Graph] Filtered to \(filteredExercises.count) completed exercises in time range")

            // Count muscle group usage
            var muscleGroupCounts = Array(repeating: 0.0, count: muscleGroups.count)

            for exercise in filteredExercises {
                let muscleGroup = exercise.muscleGroup.lowercased()
                if let index = muscleGroups.firstIndex(of: muscleGroup) {
                    // Count the number of sets in this exercise
                    let setsCount = exercise.sets?.count ?? 0
                    muscleGroupCounts[index] += Double(setsCount)
                    debugPrint("[Graph] Added \(setsCount) sets for \(muscleGroup)")
                }
            }

            debugPrint("[Graph] Raw muscle group counts: \(muscleGroupCounts)")

            // If no data found, show empty chart
            if muscleGroupCounts.allSatisfy({ $0 == 0 }) {
                chartValues = Array(repeating: 0.0, count: muscleGroups.count)
                chartMax = 1.0
                debugPrint("[Graph] No data found, showing empty chart")
                return
            }

            // Apply scaling and minimum values
            let maxValue = muscleGroupCounts.max() ?? 1.0
            let safeMax = max(maxValue, 1.0)
            let dynamicMin = max(1.0, safeMax * 0.2)

            // Apply minimum values to avoid zero values in radar chart
            let scaledValues = muscleGroupCounts.map { count in
                return count > 0 ? max(count, dynamicMin) : dynamicMin
            }

            chartValues = scaledValues
            chartMax = safeMax

            debugPrint("[Graph] Final chart values: \(chartValues)")
            debugPrint("[Graph] Chart max: \(chartMax)")

        } catch {
            debugPrint("[Graph] Error fetching exercises: \(error)")
            // Fallback to config values or minimal chart
            chartValues = config.graphDataValues.isEmpty ? Array(repeating: 1.0, count: muscleGroups.count) : config.graphDataValues
            chartMax = max(chartValues.max() ?? 1.0, 1.0)
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RadarBackground(levels: 3)
                    .stroke(Color.gray, lineWidth: 1)
                    .opacity(0.5)

                // Only show red radar chart if there's actual data
                if chartValues.contains(where: { $0 > 0 }) {
                    RadarChart(values: chartValues, maxValue: chartMax)
                        .fill(Color.red.opacity(0.4))
                        .overlay(
                            RadarChart(values: chartValues, maxValue: chartMax)
                                .stroke(Color.red, lineWidth: 2)
                        )
                }
            }
            .padding(.top, 6)
            .frame(width: 250, height: 250)
            .padding()
        }
        .onAppear {
            debugPrint("[Graph] View appeared with range: \(range)")
            calculateMuscleGroupData()
        }
        .onChange(of: range) { newRange in
            debugPrint("[Graph] Range changed to: \(newRange)")
            calculateMuscleGroupData()
        }
        .id("\(range.rawValue)")  // Force view recreation when range changes
    }
}
