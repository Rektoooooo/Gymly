//
//  SetEditorView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 20.09.2024.
//

import SwiftUI

struct EditExerciseSetView: View {
    
    @Environment(\.modelContext) private var context
    @EnvironmentObject var config: Config
    @Environment(\.dismiss) var dismiss

    @Binding var weight: Int
    @Binding var reps: Int
    @Binding var unit: String
    @Binding var setNumber: Int	
    @Binding var note: String
    @State var exercise:Exercise
    @Binding var failure:Bool
    @Binding var warmup:Bool
    @Binding var restPause:Bool
    @Binding var dropSet:Bool
    @Binding var bodyWeight:Bool
    
    var convertedWeight: Int {
        if config.weightUnit == "Kg" {
            return weight // Keep it as is
        } else {
            return weight * Int(2.20462) // Convert Kg to Lbs
        }
    }

    var body: some View {
        NavigationView {
            List {
                Section("Set note") {
                       TextField("Set note", text: $note)
                }
                Section("Set type") {
                    Toggle("Warm Up", isOn: $warmup)
                        .toggleStyle(CheckToggleStyle())
                    Toggle("Failure", isOn: $failure)
                        .toggleStyle(CheckToggleStyle())
                    Toggle("Rest Pause", isOn: $restPause)
                        .toggleStyle(CheckToggleStyle())
                    Toggle("Drop Set", isOn: $dropSet)
                        .toggleStyle(CheckToggleStyle())
                }
                Section("Weight (\(unit))") {
                    HStack {
                        Button {
                            weight -= (config.weightUnit == "Kg" ? 1 : 1 / Int(2.20462)) // Adjust decrement for Lbs
                        } label: {
                            HStack {
                                Image(systemName: "minus")
                                Label("", systemImage: "1.square")
                            }
                        }
                        .font(.title2)
                        .buttonStyle(PlainButtonStyle())

                        Button {
                            weight -= (config.weightUnit == "Kg" ? 5 : 5 / Int(2.20462)) // Adjust decrement for Lbs
                        } label: {
                            Label("", systemImage: "5.square")
                                .padding(.leading , -15)
                        }
                        .font(.title2)
                        .buttonStyle(PlainButtonStyle())

                        Spacer()
                        Text("\(convertedWeight) \(unit)")
                            .font(.title2)
                        Spacer()

                        Button {
                            weight += (config.weightUnit == "Kg" ? 5 : 5 / Int(2.20462)) // Adjust increment for Lbs
                        } label: {
                            Label("", systemImage: "5.square")
                                .padding(.trailing , -15)
                        }
                        .font(.title2)
                        .buttonStyle(PlainButtonStyle())

                        Button {
                            weight += (config.weightUnit == "Kg" ? 1 : 1 / Int(2.20462)) // Adjust increment for Lbs
                        } label: {
                            HStack {
                                Label("", systemImage: "1.square")
                                Image(systemName: "plus")
                                    .padding(.leading , -20)
                            }
                        }
                        .font(.title2)
                        .buttonStyle(PlainButtonStyle())
                    }
                    Toggle("Body Weight", isOn: $bodyWeight)
                        .toggleStyle(CheckToggleStyle())
                }
                Section("Repetisitions") {
                    HStack {
                        Button {
                            reps -= 1
                        } label: {
                            HStack {
                                Image(systemName: "minus")
                                Label("", systemImage: "1.square")
                            }
                        }
                        .font(.title2)
                        .buttonStyle(PlainButtonStyle())
                        Button {
                            reps -= 5
                        } label: {
                            Label("", systemImage: "5.square")
                                .padding(.leading , -15)
                        }
                        .font(.title2)
                        .buttonStyle(PlainButtonStyle())
                        Spacer()
                        Text("\(reps)")
                            .font(.title2)
                        Spacer()
                        Button {
                            reps += 5
                        } label: {
                            Label("", systemImage: "5.square")
                                .padding(.trailing , -15)
                        }
                        .font(.title2)
                        .buttonStyle(PlainButtonStyle())
                        Button {
                            reps += 1
                        } label: {
                            HStack {
                                Label("", systemImage: "1.square")
                                Image(systemName: "plus")
                                    .padding(.leading , -20)
                            }
                        }
                        .font(.title2)
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .offset(y : -20)
            .navigationTitle("Record set")
            .navigationBarTitleDisplayMode(.inline)
        }
        Button("Save") {
            exercise.sets[setNumber].weight = weight
            exercise.sets[setNumber].reps = reps
            exercise.sets[setNumber].failure = failure
            exercise.sets[setNumber].warmUp = warmup
            exercise.sets[setNumber].restPause = restPause
            exercise.sets[setNumber].dropSet = dropSet
            exercise.sets[setNumber].time = getCurrentTime()
            exercise.sets[setNumber].note = note
            exercise.sets[setNumber].bodyWeight = bodyWeight
            do {
                try context.save()
            } catch {
                debugPrint(error)
            }
            dismiss()
        }
        .padding(20)
    }
    
    func getCurrentTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "H:mm"
        let currentTime = dateFormatter.string(from: Date())
        return currentTime.lowercased()
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


