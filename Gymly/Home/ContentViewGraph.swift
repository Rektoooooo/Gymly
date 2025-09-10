//
//  ContentViewGraph.swift
//  Gymly
//
//  Created by Sebastián Kučera on 24.09.2024.
//

import SwiftUI
import SwiftData

struct ContentViewGraph: View {
    @EnvironmentObject var config: Config
    @Environment(\.modelContext) private var modelContext
    var range: TimeRange
    @State private var chartValues: [Double] = []
    @State private var chartMax: Double = 1.0

    enum TimeRange: String, CaseIterable, Identifiable {
        case day = "Day"
        case week = "Week"
        case month = "Month"
        case all = "All"
        var id: String { rawValue }
    }

    private var cal: Calendar { Calendar.current }
    private func startOfDay(_ d: Date) -> Date { cal.startOfDay(for: d) }
    private func startOfWeek(_ d: Date) -> Date { cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: d)) ?? startOfDay(d) }
    private func startOfMonth(_ d: Date) -> Date { cal.date(from: cal.dateComponents([.year, .month], from: d)) ?? startOfDay(d) }

    private func fetchAndAggregate(reference: Date = Date()) {
        // Determine window
        let from: Date?
        switch range {
        case .day:   from = startOfDay(reference)
        case .week:  from = startOfWeek(reference)
        case .month: from = startOfMonth(reference)
        case .all:   from = nil
        }

        do {
            let predicate: Predicate<GraphEntry>?
            if let from {
                predicate = #Predicate<GraphEntry> { entry in
                    entry.date >= from
                }
            } else {
                predicate = nil
            }

            var descriptor: FetchDescriptor<GraphEntry>
            if let predicate {
                descriptor = FetchDescriptor<GraphEntry>(predicate: predicate, sortBy: [SortDescriptor(\.date)])
            } else {
                descriptor = FetchDescriptor<GraphEntry>(sortBy: [SortDescriptor(\.date)])
            }

            let entries = try modelContext.fetch(descriptor)

            // Reduce: sum values across the selected window
            guard let count = entries.first?.data.count else {
                chartValues = config.graphDataValues // fallback to in-memory if no persisted data yet
                chartMax = max(chartValues.max() ?? 1.0, 1.0)
                return
            }
            var accum = Array(repeating: 0.0, count: count)
            for e in entries { for i in 0..<count { accum[i] += e.data[i] } }

            // Apply the same min/max logic as your builder
            let computedMax = accum.max() ?? 1.0
            let safeMax = max(computedMax, 1.0)
            let dynamicMin = max(1.0, safeMax * 0.2)
            let clamped = accum.map { max(dynamicMin, $0) }

            chartValues = clamped
            chartMax = safeMax
        } catch {
            debugPrint("[Graph] fetch error: \(error)")
            chartValues = config.graphDataValues
            chartMax = max(chartValues.max() ?? 1.0, 1.0)
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RadarBackground(levels: 3)
                    .stroke(Color.gray, lineWidth: 1)
                    .opacity(0.5)

                RadarChart(values: chartValues, maxValue: chartMax)
                    .fill(Color.red.opacity(0.4))
                    .overlay(
                        RadarChart(values: chartValues, maxValue: chartMax)
                            .stroke(Color.red, lineWidth: 2)
                    )
            }
            .padding(.top, 6)
            .frame(width: 250, height: 250)
            .padding()
        }
        .onAppear {
            fetchAndAggregate()
        }
        .onChange(of: range) {
            fetchAndAggregate()
        }
        .onChange(of: config.graphDataValues) {
            // If in-memory changes (e.g., after a workout), refresh the view
            fetchAndAggregate()
        }
    }
}
