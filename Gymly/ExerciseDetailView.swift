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
    
    var body: some View {
        NavigationView {
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
                Spacer()
                List {
                    ForEach(0...(exercise.sets.count - 1), id: \.self) { i in
                        Section("Set \(i + 1)") {
                            Button {
                                weight = exercise.sets[i].weight
                                reps = exercise.sets[i].reps
                                failure = exercise.sets[i].failure
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
                    SetEditorView(weight: $weight, reps: $reps, failure: $failure, unit: $config.weightUnit)
                        .presentationDetents([.fraction(0.5)])
                })
                .toolbar {
                    Button {
                        // add new set
                    } label: {
                        Label("Add set", systemImage: "plus.circle")
                    }
                }
                .navigationTitle("\(exercise.name)")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

        
        
        struct CheckToggleStyle: ToggleStyle {
            func makeBody(configuration: Configuration) -> some View {
                Button {
                    configuration.isOn.toggle()
                } label: {
                    Label {
                        configuration.label
                    } icon: {
                        Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(configuration.isOn ? Color.accentColor : .secondary)
                            .accessibility(label: Text(configuration.isOn ? "Checked" : "Unchecked"))
                            .imageScale(.large)
                    }
                }
                .buttonStyle(.plain)
            }
        }
