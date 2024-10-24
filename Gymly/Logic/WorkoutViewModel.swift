//
//  WorkoutViewModel.swift
//  Gymly
//
//  Created by Sebastián Kučera on 23.10.2024.
//

import Foundation
import SwiftData
import SwiftUI

final class WorkoutViewModel: ObservableObject {
    
    @Published var days: [Day] = []
    @Published var exercises:[Exercise] = []
    @Published var day:Day = Day(name: "", dayOfSplit: 0, exercises: [],date: "")
    @Published var muscleGroups:[MuscleGroup] = []
    @Published var editPlan:Bool = false
    @Published var addExercise:Bool = false
    @Published var muscleGroupNames:[String] = ["Chest","Back","Biceps","Triceps","Shoulders","Legs","Abs"]
    
    @EnvironmentObject var config: Config

    func fetchData(context: ModelContext, dayInSplit: Int) async {
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
                debugPrint("No day found")
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
    
    func insertWorkout(context: ModelContext) {
        context.insert(DayStorage(id: UUID(), day: day, date: formattedDateString(from: Date())))
        config.daysRecorded.insert(formattedDateString(from: Date()), at: 0)
        do {
            try context.save()
            debugPrint("Day saved with date : \(formattedDateString(from: Date()))")
        } catch {
            debugPrint(error)
        }
    }
    
    func formattedDateString(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        return dateFormatter.string(from: date)
    }
    
    func numberOfNightsBetween(startDate: Date) -> UInt {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year,.month,.day,.hour,.minute,.second], from: startDate)
        components.hour = 0
        components.minute = 0
        components.second = 0
        guard let midnight = calendar.date(from: components) else { return 0 }
        return UInt(calendar.dateComponents([.day], from: midnight, to: Date.now).day ?? 0)
    }
    
    func updateDayInSplit(lastUpdatedDate: Date, splitLength: Int, dayInSplit: Int) -> Int {
        let calendar = Calendar.current
        if !calendar.isDateInToday(lastUpdatedDate) {
            let daysToLastUpdate = Int(numberOfNightsBetween(startDate: lastUpdatedDate))
            return (daysToLastUpdate % splitLength) + 1
        } else {
            return dayInSplit
        }
    }
}
    
