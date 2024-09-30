//
//  CalendarDayView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 30.09.2024.
//

import SwiftUI
import SwiftData

struct CalendarDayView: View {
    let day: String
    @State private var days: [DayStorage] = []
    @Environment(\.modelContext) private var context
    var body: some View {
        NavigationView {
            if !days.isEmpty {
                ForEach (days[0].day.exercises) { exercise in
                    Text(exercise.name)
                }
            } else {
                Text("No data recorded")
            }
        }
        .onAppear() {
            fetchData()
        }
    }
    
    private func fetchData() {
        let predicate = #Predicate<DayStorage> {
            $0.date == day
        }
        let descriptor = FetchDescriptor<DayStorage>(predicate: predicate)
        do {
            let fetchedData = try context.fetch(descriptor)
            days = fetchedData
            if days.isEmpty {
                debugPrint("No day found for date : \(day)")
            } else {
                debugPrint("Fetched \(days.count) days")
            }
        } catch {
            debugPrint("Error fetching data: \(error)")
        }
    }

}

