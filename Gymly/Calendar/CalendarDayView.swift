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
    @State var day: Day = Day(name: "", dayOfSplit: 0, exercises: [], date: "")
    
    @State private var navigationTitle: String = ""
    @State var muscleGroups:[MuscleGroup] = []
    
    var body: some View {
        ZStack {
            if muscleGroups.isEmpty {
                VStack {
                    Spacer()
                    Text("Workout not recorded for the date")
                        .foregroundStyle(.white.opacity(0.6))
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            VStack {
                HStack {
                    Text(day.name)
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal)
                    Spacer()
                }
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
                .navigationTitle("\(date)")
                .navigationBarTitleDisplayMode(.inline)
                .task {
                    await refreshMuscleGroups()
                    debugPrint(date)
                }
            }
        }
    }
    
    func refreshMuscleGroups() async {
        day = await viewModel.fetchCalendarDay(date: date)
        debugPrint(day.name)
        muscleGroups.removeAll() // Clear array to trigger UI update
        muscleGroups = await viewModel.sortDataForCalendar(date: date) // Reassign updated data
    }
}
