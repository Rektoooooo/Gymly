//
//  TodayWorkoutView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 20.08.2024.
//

import SwiftUI
import Foundation
import SwiftData

struct TodayWorkoutView: View {
    
    let dateFormatter = DateFormatter()
    @State var currentDay:String = ""
    @State private var days: [Day] = []
    @State var day:Day = Day(name: "", dayOfWeek: "", exercises: [])
    @Environment(\.modelContext) private var context
    @State private var editPlan:Bool = false
    @State private var weekDays:[String] = ["Monday","Tuesday","Wednesday","Thursday","Friday","Sutarday","Sunday"]
    @State var muscleGroupNames:[String] = ["Chest","Back","Biceps","Triceps","Shoulders","Legs","Abs"]
    @State private var currentGroup:String = ""
    @State private var exercises:[Exercise] = []
    @State var muscleGroups:[MuscleGroup] = []

    var body: some View {
        NavigationView{
            List {
                ForEach(muscleGroups, id: \.self) { muscleGroup in
                    if !muscleGroup.exercises.isEmpty {
                        Section(header: Text(muscleGroup.name)) {
                            ForEach(muscleGroup.exercises, id: \.self) { exercise in
                                NavigationLink("\(exercise.name)") {
                                    ExerciseDetailView(exercise: exercise)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(day.name)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                Button {
                    editPlan = true
                } label: {
                    Label("", systemImage: "ellipsis.circle")
                }
            }
        }
        .onAppear {
            dateFormatter.dateFormat = "EEEE"
            currentDay = dateFormatter.string(from: Date())
            Task {
                await fetchData()
            }
        }
        .sheet(isPresented: $editPlan) {
            SplitView()
        }
    }
    
    private func fetchData() async {
        let predicate = #Predicate<Day> {
            $0.dayOfWeek == currentDay
        }
        let descriptor = FetchDescriptor<Day>(predicate: predicate)
        do {
            let fetchedData = try context.fetch(descriptor)
            days = []
            exercises = []
            days = fetchedData
            if days.isEmpty {
                debugPrint("No day found for name: \(currentDay)")
            } else {
                if let firstDay = days.first {
                    day = firstDay
                }
                muscleGroups = []
                for name: String in muscleGroupNames {
                    let exercises = day.exercises.filter { exercise in
                        return exercise.muscleGroup.contains(name)
                    }
                    let group = MuscleGroup(name: name, count: 0, exercises: exercises)
                    muscleGroups.append(group)
                }
                debugPrint("Fetched day: \(days[0].name)")
            }
        } catch {
            debugPrint("Error fetching data: \(error)")
        }
    }
    
}

#Preview {
    TodayWorkoutView(currentDay: "")
}
