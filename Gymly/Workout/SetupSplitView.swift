//
//  SetupSplitView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 17.10.2024.
//

import SwiftUI

struct SetupSplitView: View {
    @State private var splitLength: String = ""
    @State private var splitDay: String = ""
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @EnvironmentObject var config: Config
    @ObservedObject var viewModel: WorkoutViewModel

    
    var body: some View {
        Form {
            Section("How many days is your split ?") {
                TextField("7", text: $splitLength)
                    .keyboardType(.numbersAndPunctuation)
            }
            Section("What is your current day in the split") {
                TextField("1", text: $splitDay)
                    .keyboardType(.numbersAndPunctuation)
            }
        }
        Button("Start your split") {
            if viewModel.days.isEmpty {
                for i in 0...(Int(splitLength) ?? 1) - 1 {
                    viewModel.addDay(name: "Day \(i + 1)", index: i + 1)
                }
                debugPrint("Added days")
                do {
                    try context.save()
                    debugPrint("Context saved")
                } catch {
                    debugPrint(error)
                }
                config.splitStarted = true
                config.dayInSplit = Int(splitDay) ?? 1
                config.lastUpdateDate = Date()
                config.splitLenght = Int(splitLength) ?? 1
                dismiss()
            } else {
                debugPrint("Days already exist, skipping insertion.")
            }
        }
        .padding()
        .background(Color.graytint)
        .cornerRadius(20)
        .padding()
    }
    
}
