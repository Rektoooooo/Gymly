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
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("\(exercise.sets) Sets")
                        .padding()
                        .foregroundStyle(.accent)
                        .bold()
                    Spacer()
                    Text("\(exercise.reps) Reps")
                        .padding()
                        .foregroundStyle(.accent)
                        .bold()
                }
                Spacer()
                List {
                    ForEach(0...(exercise.sets - 1), id: \.self) { i in
                        Section("Set \(i + 1)") {
                            HStack {
                                Picker("", selection: $exercise.setWeights[i]) {
                                    ForEach(1...999, id: \.self) { number in
                                        Text("\(number)")
                                    }
                                }
                                .pickerStyle(.wheel)
                                .padding(-8)
                                .frame(width: 60,height: 35)
                                Text("\(config.weightUnit)")
                                    .offset(x: -5)
                                Spacer()
                                Picker("", selection: $exercise.setRepsDone[i]) {
                                    ForEach(1...100, id: \.self) { number in
                                        Text("\(number)")
                                    }
                                }
                                .pickerStyle(.wheel)
                                .padding(-8)
                                .frame(width: 40,height: 35)
                                Text("Reps")
                                Spacer()
                                Toggle(isOn: $exercise.setFailuer[i]) {}
                                    .toggleStyle(CheckToggleStyle())
                                Text("Failure")
                            }
                        }
                    }
                    Section("") {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            }
        }
        .onAppear() {
        }
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
