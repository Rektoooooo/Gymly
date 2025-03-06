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

    @Binding var weight: Double
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
    
    var selectedSetTypes: [String] {
        var selected = [String]()
        if failure { selected.append("Failure") }
        if warmup{ selected.append("Warm Up") }
        if restPause { selected.append("Rest Pause") }
        if dropSet { selected.append("Drop Set") }
        return selected
    }
    @State private var isDropdownOpen = false

    
    var displayedWeight: String {
        let weightInLbs = weight * 2.20462
        return config.weightUnit == "Kg" ? "\(Int(round(weight))) kg" : "\(Int(round(weightInLbs))) lbs"
    }


    var body: some View {
        NavigationView {
            List {
                Section("Set note") {
                    TextField("Set note", text: $note)
                        .onChange(of: note) { oldValue, newValue in
                            exercise.sets[setNumber].note = newValue
                            do {
                                try context.save()
                            } catch {
                                debugPrint(error)
                            }
                        }
                }
                Section(header: Text("Set Type")) {
                    Menu {
                        Button(action: {
                            failure.toggle()
                            exercise.sets[setNumber].failure = failure
                            do {
                                try context.save()
                            } catch {
                                debugPrint(error)
                            }
                        }) {
                            HStack {
                                Text("Failure")
                                Spacer()
                                if failure { Image(systemName: "checkmark") }
                            }
                        }
                        Button(action: {
                            warmup.toggle()
                            exercise.sets[setNumber].warmUp = warmup
                            do {
                                try context.save()
                            } catch {
                                debugPrint(error)
                            }
                        }) {
                            HStack {
                                Text("Warm Up")
                                Spacer()
                                if warmup { Image(systemName: "checkmark") }
                            }
                        }
                        Button(action: {
                            restPause.toggle()
                            exercise.sets[setNumber].restPause = restPause
                            do {
                                try context.save()
                            } catch {
                                debugPrint(error)
                            }
                        }) {
                            HStack {
                                Text("Rest Pause")
                                Spacer()
                                if restPause { Image(systemName: "checkmark") }
                            }
                        }
                        Button(action: {
                            dropSet.toggle()
                            exercise.sets[setNumber].dropSet = dropSet
                            do {
                                try context.save()
                            } catch {
                                debugPrint(error)
                            }
                        }) {
                            HStack {
                                Text("Drop Set")
                                Spacer()
                                if dropSet { Image(systemName: "checkmark") }
                            }
                        }
                    } label: {
                        HStack {
                            Text("Set Type:")
                            Spacer()
                            Text(selectedSetTypes.isEmpty ? "None" : selectedSetTypes.joined(separator: ", "))
                                .foregroundColor(.gray)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    }
                }
                Section("Weight (\(unit))") {
                    HStack {
                        Button {
                            decreaseWeight(by: 1)
                            saveWeight()
                        } label: {
                            HStack {
                                Image(systemName: "minus")
                                Label("", systemImage: "1.square")
                            }
                        }
                        .font(.title2)
                        .buttonStyle(PlainButtonStyle())

                        Button {
                            decreaseWeight(by: 5)
                            saveWeight()
                        } label: {
                            Label("", systemImage: "5.square")
                                .padding(.leading , -15)
                        }
                        .font(.title2)
                        .buttonStyle(PlainButtonStyle())

                        Spacer()
                        Text("\(displayedWeight)")
                            .font(.title2)
                        Spacer()

                        Button {
                            increaseWeight(by: 5)
                            saveWeight()
                        } label: {
                            Label("", systemImage: "5.square")
                                .padding(.trailing , -15)
                        }
                        .font(.title2)
                        .buttonStyle(PlainButtonStyle())

                        Button {
                            increaseWeight(by: 1)
                            saveWeight()
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
                        .onChange(of: bodyWeight) { _, newValue in
                            exercise.sets[setNumber].bodyWeight = newValue
                            do {
                                try context.save()
                            } catch {
                                debugPrint(error)
                            }
                        }
                }
                Section("Repetisitions") {
                    HStack {
                        Button {
                            reps -= 1
                            saveReps()
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
                            saveReps()
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
                            saveReps()
                        } label: {
                            Label("", systemImage: "5.square")
                                .padding(.trailing , -15)
                        }
                        .font(.title2)
                        .buttonStyle(PlainButtonStyle())
                        Button {
                            reps += 1
                            saveReps()
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
            .scrollDisabled(true)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
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
                    } label: {
                        Text("Done")
                            .foregroundStyle(Color.accentColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.1))
                            .bold()
                            .cornerRadius(10)
                    }
                }
            }
            .offset(y : -20)
            .navigationTitle("Record set")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func getCurrentTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "H:mm"
        let currentTime = dateFormatter.string(from: Date())
        return currentTime.lowercased()
    }
    
    func increaseWeight(by value: Int) {
        if config.weightUnit == "Kg" {
            weight += Double(value)
        } else {
            weight += Double(value) / 2.20462 // Convert lbs to kg before adding
        }
    }

    func decreaseWeight(by value: Int) {
        if config.weightUnit == "Kg" {
            weight -= Double(value)
        } else {
            weight -= Double(value) / 2.20462 // Convert lbs to kg before subtracting
        }
    }

    private func saveWeight() {
        exercise.sets[setNumber].weight = weight
        do {
            try context.save()
        } catch {
            debugPrint(error)
        }
    }

    private func saveReps() {
        exercise.sets[setNumber].reps = reps
        do {
            try context.save()
        } catch {
            debugPrint(error)
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
