//
//  CopyWorkout.swift
//  Gymly
//
//  Created by Sebastián Kučera on 12.09.2024.
//

import SwiftUI
import SwiftData

struct CopyWorkoutView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    @State var day:Day
    @State private var days: [Day] = []
    @State var workoutNames: [String] = []
    @State var selected: String = ""
    @State private var selectedDays: [Day] = []
    @State var fetchedExercises: [Exercise] = []

    
    // TODO: Make copying exercises possible
    var body: some View {
        NavigationView {
            List {
                Picker("Chose workout", selection: $selected) {
                    ForEach(workoutNames, id: \.self) {
                        Text($0)
                    }
                    .pickerStyle(.inline)
                }
                Button("Copy \(selected)") {
                    dismiss()
                }
            }
            .offset(y: -30)
            .onAppear {
                selected = day.name
            }
            .navigationTitle("Copy workout")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

