//
//  CalendarDayView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 30.09.2024.
//


import SwiftUI
import Foundation
import SwiftData

struct CalendarDayView: View {
    
    @ObservedObject var viewModel: WorkoutViewModel
    @EnvironmentObject var config: Config
    @Environment(\.modelContext) var context: ModelContext
    
    @State var date: String
    
    @State private var navigationTitle: String = ""
    @State var muscleGroups:[MuscleGroup] = []
    
    var body: some View {
        NavigationView{
            List {
                ForEach(muscleGroups) { group in
                    if !group.exercises.isEmpty {
                        Section(header: Text(group.name)) {
                            ForEach(group.exercises, id: \.id) { exercise in
                                NavigationLink(destination: CalendarExerciseView(viewModel: WorkoutViewModel(config: config, context: context), exercise: exercise)) {
                                    Text(exercise.name)
                                }
                            }
                        }
                    }
                }
            }
            .id(UUID())
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.large)
        }
        .task {
                await refreshMuscleGroups()
                navigationTitle = viewModel.day.name
            debugPrint(date)
        }
    }
    
    func refreshMuscleGroups() async {
        muscleGroups.removeAll() // Clear array to trigger UI update
        muscleGroups = await viewModel.sortDataForCalendar(date: date) // Reassign updated data
    }
}
