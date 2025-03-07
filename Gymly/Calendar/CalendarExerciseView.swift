//
//  CalendarExerciseView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 01.10.2024.
//

import SwiftUI
import SwiftData

struct CalendarExerciseView: View {
    
    @Environment(\.modelContext) private var context
    @EnvironmentObject var config: Config
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: WorkoutViewModel
    @State var exercise: Exercise
    @State private var isOn = false
    @State var showSheet = false
    @State var weight: Double = 0.0
    @State var reps: Int = 0
    @State var failure: Bool = false
    @State var warmUp: Bool = false
    @State var restPause: Bool = false
    @State var dropSet: Bool = false
    @State var bodyWeight: Bool = false
    @State var setNumber: Int = 0
    @State var note: String = ""
    
    /// Converts weight to correct unit (Kg/Lbs)
    var convertedWeight: Double {
        if config.weightUnit == "Kg" {
            return weight
        } else {
            return weight * 2.20462
        }
    }

    var body: some View {
        VStack {
            HStack {
                Text("\(exercise.sets.count) Sets")
                    .foregroundStyle(.accent)
                    .padding()
                    .bold()
                Spacer()
                Text("\(exercise.repGoal) Reps")
                    .foregroundStyle(.accent)
                    .padding()
                    .bold()
            }
            Form {
                /// List of exercise sets
                ForEach(Array(exercise.sets.sorted(by: { $0.createdAt < $1.createdAt }).enumerated()), id: \.element.id) { index, set in
                    SetCell(
                        viewModel: viewModel,
                        index: index,
                        set: set,
                        config: config,
                        loadSetData: loadSetData,
                        exercise: exercise,
                        setForCalendar: true
                    )
                }
            }
        }
        .navigationTitle("\(exercise.name)")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    /// Empty func so i can reuse the SetCell
    func loadSetData(set: Exercise.Set, shouldOpenSheet: Bool = false) {}
    
    func refreshExercise() {
        Task {
            exercise = await viewModel.fetchExercise(id: exercise.id)
        }
    }
}

