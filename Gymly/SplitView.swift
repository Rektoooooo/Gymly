//
//  WorkoutView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 13.05.2024.
//

import SwiftUI
import SwiftData

struct SplitView: View {
    @Environment(\.modelContext) private var context
    @State private var days: [Day] = []
    var sortedDays: [Day] {
        let weekdaysOrder = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        return days.sorted {
            guard let firstIndex = weekdaysOrder.firstIndex(of: $0.dayOfWeek),
                  let secondIndex = weekdaysOrder.firstIndex(of: $1.dayOfWeek) else {
                return false
            }
            return firstIndex < secondIndex
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section("Workout list") {
                        ForEach(sortedDays, id: \.self) { day in
                            NavigationLink("\(day.dayOfWeek) - \(day.name)") {
                                WorkoutDayView(name: day.name, day: day)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Edit Split")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            fetchData()
        }
    }
    
    private func fetchData() {
        let predicate = #Predicate<Day> {
            $0.name == $0.name
        }
        let descriptor = FetchDescriptor<Day>(predicate: predicate)
        do {
            let fetchedData = try context.fetch(descriptor)
            days = fetchedData
            if days.isEmpty {
                debugPrint("No day found for name:")
            } else {
                debugPrint("Fetched \(days.count) days")
            }
        } catch {
            debugPrint("Error fetching data: \(error)")
        }
    }
    
}
