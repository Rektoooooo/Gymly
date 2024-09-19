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
    @State var muscleGroups:[String] = ["Chest","Back","Biceps","Triceps","Shoulders","Legs","Abs"]
    @State private var currentGroup:String = ""
    @State private var exercises:[Exercise] = []
    
    var body: some View {
        NavigationView{
            List {
                ForEach(muscleGroups, id: \.self) { muscle in
                    let exercisesForMuscle = day.exercises.filter { $0.muscleGroup == muscle }
                    if !exercisesForMuscle.isEmpty {
                        Section(header: Text(muscle)) {
                            ForEach(exercisesForMuscle, id: \.self) { exercise in
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
            .onAppear {
                dateFormatter.dateFormat = "EEEE"
                currentDay = dateFormatter.string(from: Date())
                fetchData()
                day = days[0]
            }
        }
        .sheet(isPresented: $editPlan) {
            SplitView()
        }
    }
    
    private func fetchData() {
        let predicate = #Predicate<Day> {
            $0.dayOfWeek == currentDay
        }
        let descriptor = FetchDescriptor<Day>(predicate: predicate)
        do {
            let fetchedData = try context.fetch(descriptor)
            days = []
            days = fetchedData
            for exercise in day.exercises {
                exercises.append(exercise)
            }
            if days.isEmpty {
                debugPrint("No day found for name: \(currentDay)")
            } else {
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
