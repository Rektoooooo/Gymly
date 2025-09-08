//
//  SetCellView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 07.03.2025.
//


import SwiftUI

struct SetCell: View {
    @ObservedObject var viewModel: WorkoutViewModel
    var index: Int
    var set: Exercise.Set
    var config: Config
    var loadSetData: (Exercise.Set, Bool) -> Void
    var exercise: Exercise
    var setForCalendar: Bool

    var body: some View {
        Section("Set \(index + 1)") {
            Button {
                if setForCalendar == false {
                    loadSetData(set, true)
                }
            } label: {
                HStack {
                    /// Display set details (weight, reps, notes)
                    HStack {
                        if set.bodyWeight {
                            Text("BW  +")
                                .foregroundStyle(.accent)
                                .bold()
                        }
                        Text("\(Int(round(Double(set.weight) * (config.weightUnit == "Kg" ? 1.0 : 2.20462))))")
                            .foregroundStyle(.accent)
                            .bold()
                        Text("\(config.weightUnit)")
                            .foregroundStyle(.accent)
                            .opacity(0.6)
                            .offset(x: -5)
                    }
                    HStack {
                        Text("\(set.reps)")
                            .foregroundStyle(Color.green)
                            .bold()
                        Text("Reps")
                            .foregroundStyle(Color.green)
                            .opacity(0.6)
                            .offset(x: -5)
                    }
                    HStack {
                        if set.failure {
                            Text("F")
                                .foregroundStyle(Color.red)
                                .offset(x: -5)
                        }
                        if set.warmUp {
                            Text("W")
                                .foregroundStyle(Color.orange)
                                .offset(x: -5)
                        }
                        if set.restPause {
                            Text("RP")
                                .foregroundStyle(Color.green)
                                .offset(x: -5)
                        }
                        if set.dropSet {
                            Text("DS")
                                .foregroundStyle(Color.blue)
                                .offset(x: -5)
                        }
                    }
                    Spacer()
                    Text("\(set.time)")
                        .foregroundStyle(Color.white)
                        .opacity(set.time.isEmpty ? 0 : 0.3)
                }
            }

            if !set.note.isEmpty {
                Text(set.note)
                    .foregroundStyle(Color.white)
                    .opacity(0.5)
            }
        }
    }
}
