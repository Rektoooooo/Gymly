//
//  ExerciseDetailView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 14.05.2024.
//

import SwiftUI
import SwiftData

struct ExerciseDetailView: View {
    
    @Environment(\.modelContext) private var context
    @EnvironmentObject var config: Config
    @Environment(\.dismiss) var dismiss
    
    @State var exercise:Exercise
    @State private var isOn = false
    let conversionFactor = 2.20462 // 1 kg = 2.20462 lbs
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
                            showSheet = true
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
                Section("") {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showSheet, onDismiss: {
                
            } ,content: {
                SetEditorView(weight: $weight, reps: $reps, failure: $failure, unit: $config.weightUnit,setNumber: $setNumber, exercise: exercise)
                    .presentationDetents([.fraction(0.55)])
            })
            .toolbar {
                Button {
                    // add new set
                } label: {
                    Label("Add set", systemImage: "plus.circle")
                }
            }
        }
        .navigationTitle("\(exercise.name)")
        .navigationBarTitleDisplayMode(.inline)
    }
}


