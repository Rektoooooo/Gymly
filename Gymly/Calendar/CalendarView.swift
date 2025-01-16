//
//  CalendarView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 30.08.2024.
//

import SwiftUI

struct CalendarView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @State private var currentMonth = Date()
    @EnvironmentObject var config: Config
    let calendar = Calendar.current
    let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button(action: {
                        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                    }) {
                        Image(systemName: "chevron.left")
                            .bold()
                            .foregroundStyle(.red)
                    }
                    Spacer()
                    Text(monthAndYearString(from: currentMonth))
                        .font(.title)
                    Spacer()
                    Button(action: {
                        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                    }) {
                        Image(systemName: "chevron.right")
                            .bold()
                            .foregroundStyle(.red)
                    }
                }
                .padding()
                
                VStack {
                    HStack {
                        ForEach(daysOfWeek, id: \.self) { day in
                            Spacer()
                            Text(day)
                                .frame(width: UIScreen.main.bounds.width * 0.085)
                                .bold()
                                .font(.subheadline)
                            Spacer()
                        }
                    }
                    .padding(5)
                    .background(Color.red)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.red, lineWidth: 4)
                    )
                    .padding(.bottom, 10)
                    
                    let daysInMonth = getDaysInMonth(for: currentMonth)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                        ForEach(daysInMonth.indices, id: \.self) { index in
                            let day = daysInMonth[index]
                            
                            if day.day != 0 {
                                if formattedDateString(from: day.date) == formattedDateString(from: Date()) {
                                    NavigationLink("\(day.day)") {
                                        CalendarDayView(viewModel: viewModel, date: formattedDateString(from: day.date))
                                    }
                                    .frame(width: UIScreen.main.bounds.width * 0.085, height: UIScreen.main.bounds.height * 0.04)
                                    .font(.system(size: 22))
                                    .foregroundColor(Color.white)
                                    .padding(.horizontal, 3)
                                    .padding(.vertical, 2)
                                    .background(Color.red)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(.red, lineWidth: 4)
                                    )
                                    .fontWeight(.bold)
                                    .padding(3)
                                } else {
                                    ZStack {
                                        NavigationLink("\(day.day)") {
                                            CalendarDayView(viewModel: viewModel, date: formattedDateString(from: day.date))
                                        }
                                        .frame(width: UIScreen.main.bounds.width * 0.085, height: UIScreen.main.bounds.height * 0.04)
                                        .font(.system(size: 22))
                                        .foregroundColor(Color.white)
                                        .fontWeight(.bold)
                                        .padding(3)
                                        
                                        if config.daysRecorded.contains(formattedDateString(from: day.date)) {
                                            Circle()
                                                .frame(width: 10, height: 10)
                                                .foregroundColor(.red)
                                                .offset(x: 0, y: 20)
                                        }
                                    }
                                }
                            } else {
                                Text("")
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 6)
                            }
                        }
                    }
                    .padding(2)
                    .background(Color.graytint)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.graytint, lineWidth: 4)
                    )
                    Spacer()
                }
                .frame(maxWidth: UIScreen.main.bounds.width * 0.92)
            }
            .navigationTitle("Calendar")
            .onAppear() {
                currentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date())) ?? currentMonth
            }
        }
    }

    func monthAndYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    func formattedDateString(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        
        // Set the desired format: "d MMMM yyyy" (e.g., "30 September 2024")
        dateFormatter.dateFormat = "d MMMM yyyy"
        
        // Convert the date to the string using the formatter
        return dateFormatter.string(from: date)
    }

    func getDaysInMonth(for date: Date) -> [DayCalendar] {
        guard let range = calendar.range(of: .day, in: .month, for: date),
              let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else {
            return []
        }

        // Find which weekday the first day of the month falls on
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        var days: [DayCalendar] = []

        // Add empty days for the gap before the first day of the month
        let offset = (firstWeekday + 5) % 7 // Adjust for Monday as the first day
        days.append(contentsOf: Array(repeating: DayCalendar(day: 0, date: Date()), count: offset))

        // Add the actual days of the month
        days.append(contentsOf: range.compactMap { day -> DayCalendar? in
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                return DayCalendar(day: day, date: date)
            }
            return nil
        })

        return days
    }
}

struct DayCalendar: Hashable {
    var id = UUID()
    let day: Int
    let date: Date
}

