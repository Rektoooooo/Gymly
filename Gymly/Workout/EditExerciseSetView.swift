//
//  SetEditorView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 20.09.2024.
//

import SwiftUI

struct EditExerciseSetView: View {
    
    /// Environment and observed objects
    @Environment(\.modelContext) private var context
    @EnvironmentObject var config: Config
    @Environment(\.dismiss) var dismiss

    /// Bindings for exercise set data
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
    
    /// Returns a list of selected set types
    var selectedSetTypes: [String] {
        var selected = [String]()
        if failure { selected.append("Failure") }
        if warmup{ selected.append("Warm Up") }
        if restPause { selected.append("Rest Pause") }
        if dropSet { selected.append("Drop Set") }
        return selected
    }
    @State private var isDropdownOpen = false

    /// Formats displayed weight based on the unit
    var displayedWeight: String {
        let weightInLbs = weight * 2.20462
        return config.weightUnit == "Kg" ? "\(Int(round(weight))) kg" : "\(Int(round(weightInLbs))) lbs"
    }


    var body: some View {
        NavigationView {
            List {
                /// Section for setting a note
                Section("Set note") {
                    SetNoteCell(
                        note: $note,
                        setNumber: setNumber,
                        exercise: exercise
                    )
                }
                /// Section for selecting set type
                Section(header: Text("Set Type")) {
                    SetTypeCell(
                        failure: $failure,
                        warmup: $warmup,
                        restPause: $restPause,
                        dropSet: $dropSet,
                        setNumber: setNumber,
                        exercise: exercise
                    )
                }
                /// Section for adjusting weight
                Section("Weight (\(unit))") {
                    WeightSelectorCell(
                        bodyWeight: $bodyWeight,
                        displayedWeight: displayedWeight,
                        setNumber: setNumber,
                        exercise: exercise,
                        increaseWeight: increaseWeight,
                        decreaseWeight: decreaseWeight,
                        saveWeight: saveWeight
                    )
                }
                /// Section for adjusting repetitions
                Section("Repetitions") {
                    HStack {
                        RepetitionCell(reps: $reps, saveReps: saveReps)
                    }
                }
            }
            .scrollDisabled(true)
            .toolbar {
                /// Toolbar button to save changes
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
    
    /// Get current time for set
    func getCurrentTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "H:mm"
        let currentTime = dateFormatter.string(from: Date())
        return currentTime.lowercased()
    }
    
    /// Increase the weight
    func increaseWeight(by value: Int) {
        if config.weightUnit == "Kg" {
            weight += Double(value)
        } else {
            weight += Double(value) / 2.20462 // Convert lbs to kg before adding
        }
    }

    /// Decrease the weight
    func decreaseWeight(by value: Int) {
        if config.weightUnit == "Kg" {
            weight -= Double(value)
        } else {
            weight -= Double(value) / 2.20462 // Convert lbs to kg before subtracting
        }
    }

    /// Save weight to context
    private func saveWeight() {
        exercise.sets[setNumber].weight = weight
        do {
            try context.save()
        } catch {
            debugPrint(error)
        }
    }

    /// Save reps to context
    private func saveReps() {
        exercise.sets[setNumber].reps = reps
        do {
            try context.save()
        } catch {
            debugPrint(error)
        }
    }
}
