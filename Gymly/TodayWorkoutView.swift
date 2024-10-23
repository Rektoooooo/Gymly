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
    @State var day:Day = Day(name: "", dayOfSplit: 0, exercises: [],date: "")
    @Environment(\.modelContext) private var context
    @EnvironmentObject var config: Config
    @State private var editPlan:Bool = false
    @State private var weekDays:[String] = ["Monday","Tuesday","Wednesday","Thursday","Friday","Sutarday","Sunday"]
    @State var muscleGroupNames:[String] = ["Chest","Back","Biceps","Triceps","Shoulders","Legs","Abs"]
    @State private var currentGroup:String = ""
    @State private var exercises:[Exercise] = []
    @State var muscleGroups:[MuscleGroup] = []
    @State var addExercise:Bool = false
    @State private var isSheetClosed = false


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
                Section("") {
                    Button("Workout done") {
                        context.insert(DayStorage(id: UUID(), day: day, date: formattedDateString(from: Date())))
                        config.daysRecorded.insert(formattedDateString(from: Date()), at: 0)
                        do {
                            try context.save()
                            debugPrint("Day saved with date : \(formattedDateString(from: Date()))")
                        } catch {
                            debugPrint(error)
                        }
                    }
                }
            }
            .id(UUID())
            .navigationTitle(day.name)
            .navigationBarTitleDisplayMode(.large)
            .onChange(of: addExercise) {
                Task {
                    await fetchData(dayInSplit: config.dayInSplit)
                }
            }
            .toolbar {
                Button {
                    editPlan = true
                } label: {
                    Label("", systemImage: "ellipsis.circle")
                }
                Button {
                    addExercise = true
                } label: {
                    Label("", systemImage: "plus.circle")
                }
            }
        }
        .onAppear {
            dateFormatter.dateFormat = "EEEE"
            currentDay = dateFormatter.string(from: Date())
            config.dayInSplit = updateDayInSplit()
            config.lastUpdateDate = Date()
            Task {
                await fetchData(dayInSplit: config.dayInSplit)
            }
        }
        .sheet(isPresented: $editPlan, onDismiss: {
            Task {
                await fetchData(dayInSplit: config.dayInSplit)
            }
        }) {
            SplitView()
        }
        .sheet(isPresented: $addExercise, onDismiss: {
            Task {
                await fetchData(dayInSplit: config.dayInSplit)
            }
        } ,content: {
            CreateExerciseView(day: day)
                .navigationTitle("Create Exercise")
                .presentationDetents([.fraction(0.5)])
        })
    }
    
    func formattedDateString(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        return dateFormatter.string(from: date)
    }
    
    private func numberOfNightsBetween(startDate: Date) -> UInt {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year,.month,.day,.hour,.minute,.second], from: startDate)
        components.hour = 0
        components.minute = 0
        components.second = 0
        guard let midnight = calendar.date(from: components) else { return 0 }
        return UInt(calendar.dateComponents([.day], from: midnight, to: Date.now).day ?? 0)
    }
    
    private func updateDayInSplit() -> Int {
        let calendar = Calendar.current
        if !calendar.isDateInToday(config.lastUpdateDate) {
            let daysToLastUpdate = Int(numberOfNightsBetween(startDate: config.lastUpdateDate))
            return (daysToLastUpdate % config.splitLenght) + 1
        } else {
            return config.dayInSplit
        }
    }
    
    private func fetchData(dayInSplit: Int) async {
        let predicate = #Predicate<Day> {
            $0.dayOfSplit == dayInSplit
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
                day = days[0]
            }
        } catch {
            debugPrint("Error fetching data: \(error)")
        }
    }
    
}

#Preview {
    TodayWorkoutView(currentDay: "")
}
