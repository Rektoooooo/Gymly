//
//  SplitView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 16.01.2025.
//

import SwiftUI
import SwiftData

struct SplitView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @EnvironmentObject var config: Config
    @Environment(\.modelContext) var context: ModelContext

    @State private var days: [Day] = []
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section("Workout list") {
                        ForEach(days.sorted(by: { $0.dayOfSplit < $1.dayOfSplit }), id: \.self) { day in
                            NavigationLink("Day \(day.dayOfSplit) - \(day.name)") {
                                WorkoutDayView(viewModel: viewModel, day: day)
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
}
