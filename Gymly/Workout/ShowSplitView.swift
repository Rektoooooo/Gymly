//
//  SplitView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 16.01.2025.
//

import SwiftUI
import SwiftData

struct ShowSplitView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @EnvironmentObject var config: Config
    @Environment(\.modelContext) var context: ModelContext

    @State private var days: [Day] = []

    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section("Workout list") {
                        let uniqueDays = removeDuplicateDays(from: days)

                        ForEach(uniqueDays.sorted(by: { $0.dayOfSplit < $1.dayOfSplit }), id: \.id) { day in
                            NavigationLink("Day \(day.dayOfSplit) - \(day.name)") {
                                ShowSplitDayView(viewModel: viewModel, day: day)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Edit Split")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await days = viewModel.fetchAllDays()
        }
    }

    /// **Helper function to remove duplicate `dayOfSplit` values**
    private func removeDuplicateDays(from days: [Day]) -> [Day] {
        var seenSplits = Set<Int>()
        return days.filter { seenSplits.insert($0.dayOfSplit).inserted } // Keep only the first occurrence
    }
}
