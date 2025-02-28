//
//  SetupSplitView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 17.10.2024.
//

import SwiftUI

struct SetupSplitView: View {
    @State private var splitLength: String = "7"
    @State private var splitDay: String = "1"
    @State private var name: String = "Push, Pull, Legs"
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @EnvironmentObject var config: Config
    @ObservedObject var viewModel: WorkoutViewModel

    
    var body: some View {
        Form {
            Section("Name your split") {
                TextField("Push, Pull, Legs", text: $name)
            }
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
            viewModel.createNewSplit(name: name, numberOfDays: Int(splitLength)!, startDate: Date(), context: context)
            config.dayInSplit = Int(splitDay)!
            dismiss()
        }
        .padding()
        .background(Color.graytint)
        .cornerRadius(20)
        .padding()
    }
    
}
