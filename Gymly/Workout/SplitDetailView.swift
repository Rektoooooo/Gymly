//
//  SplitDetailView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 27.02.2025.
//

import SwiftUI

struct SplitDetailView: View {
    @State var split: Split
    @State var days: [Day] = []
    @ObservedObject var viewModel: WorkoutViewModel
    var body: some View {
        List {
            ForEach(days.sorted(by: { $0.dayOfSplit < $1.dayOfSplit })) { day in
                NavigationLink(destination: ShowSplitDayView(viewModel: viewModel, day: day)) {
                    Text("Day \(day.dayOfSplit) - \(day.name)")
                }
            }
        }
        .task {
            days = split.days
        }
        .navigationTitle(split.name)
    }
}
