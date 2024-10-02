//
//  CalendarExerciseView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 01.10.2024.
//

import SwiftUI

struct CalendarExerciseView: View {
    
    @Environment(\.modelContext) private var context
    @EnvironmentObject var config: Config
    @Environment(\.dismiss) var dismiss
    @State var exercise:Exercise
    @State private var isOn = false
    @State var showSheet = false
    @State var weight: Int = 0
    @State var reps: Int = 0
    @State var failure:Bool = false
    @State var setNumber:Int = 0
    
    
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
            List {
                ForEach(0...(exercise.sets.count - 1), id: \.self) { i in
                    Section("Set \(i + 1)") {
                        Button {
                            weight = exercise.sets[i].weight
                            reps = exercise.sets[i].reps
                            failure = exercise.sets[i].failure
                            setNumber = i
                        } label: {
                            HStack {
                                HStack {
                                    Text("\(exercise.sets[i].weight)")
                                        .foregroundStyle(.accent)
                                        .bold()
                                    Text("\(config.weightUnit)")
                                        .foregroundStyle(.accent)
                                        .opacity(0.6)
                                        .offset(x: -5)
                                }
                                HStack {
                                    Text("\(exercise.sets[i].reps)")
                                        .foregroundStyle(Color.green)
                                        .bold()
                                    Text("Reps")
                                        .foregroundStyle(Color.green)
                                        .opacity(0.6)
                                        .offset(x: -5)
                                }
                                HStack {
                                    Text("F")
                                        .foregroundStyle(Color.red)
                                        .opacity(exercise.sets[i].failure ? 1 : 0)
                                        .offset(x: -5)
                                }
                                Spacer()
                                HStack {
                                    Text("\(exercise.sets[i].time)")
                                        .foregroundStyle(Color.white)
                                        .opacity(exercise.sets[i].time.isEmpty ? 0 : 0.3)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("\(exercise.name)")
        .navigationBarTitleDisplayMode(.inline)
    }
}

