//
//  SetTypeCell.swift
//  Gymly
//
//  Created by Sebastián Kučera on 06.03.2025.
//

import SwiftUI

struct SetTypeCell: View {
    @Environment(\.modelContext) private var context
    @Binding var failure: Bool
    @Binding var warmup: Bool
    @Binding var restPause: Bool
    @Binding var dropSet: Bool
    var setNumber: Int
    var exercise: Exercise
    
    var body: some View {
        Menu {
            ToggleButton(label: "Failure", isOn: $failure)
            ToggleButton(label: "Warm Up", isOn: $warmup)
            ToggleButton(label: "Rest Pause", isOn: $restPause)
            ToggleButton(label: "Drop Set", isOn: $dropSet)
        } label: {
            HStack {
                Text("Set Type:")
                Spacer()
                Text(selectedSetTypes().isEmpty ? "None" : selectedSetTypes().joined(separator: ", "))
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
    }
    
    /// Returns a list of selected set types
    private func selectedSetTypes() -> [String] {
        var types = [String]()
        if failure { types.append("Failure") }
        if warmup { types.append("Warm Up") }
        if restPause { types.append("Rest Pause") }
        if dropSet { types.append("Drop Set") }
        return types
    }
    
    /// Reusable button for toggling set types
    private func ToggleButton(label: String, isOn: Binding<Bool>) -> some View {
        Button(action: {
            isOn.wrappedValue.toggle()
            updateExerciseSet(for: label, with: isOn.wrappedValue)
        }) {
            HStack {
                Text(label)
                Spacer()
                if isOn.wrappedValue { Image(systemName: "checkmark") }
            }
        }
    }
    
    /// Updates the exercise set with the toggled value and saves it to Core Data
    private func updateExerciseSet(for label: String, with value: Bool) {
        guard let sets = exercise.sets, setNumber < sets.count else { return }

        switch label {
        case "Failure": exercise.sets?[setNumber].failure = value
        case "Warm Up": exercise.sets?[setNumber].warmUp = value
        case "Rest Pause": exercise.sets?[setNumber].restPause = value
        case "Drop Set": exercise.sets?[setNumber].dropSet = value
        default: break
        }
        
        do {
            try context.save()
        } catch {
            debugPrint(error)
        }
    }
}

