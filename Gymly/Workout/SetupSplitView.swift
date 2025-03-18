//
//  SetupSplitView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 17.10.2024.
//


import SwiftUI

struct SetupSplitView: View {
    
    /// User input state variables
    @State private var splitLength: String = ""
    @State private var splitDay: String = ""
    @State private var name: String = ""
    
    /// Environment objects for dismissing the view and accessing app context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @EnvironmentObject var config: Config
    @ObservedObject var viewModel: WorkoutViewModel

    var body: some View {
        Form {
            /// Section for naming the workout split
            Section("Name your split") {
                TextField("Push, Pull, Legs", text: $name)
            }
            /// Section for selecting split duration
            Section("How many days is your split ?") {
                TextField("7", text: $splitLength)
                    .keyboardType(.numbersAndPunctuation)
            }
            /// Section for selecting the starting day in the split
            Section("What is your current day in the split") {
                TextField("1", text: $splitDay)
                    .keyboardType(.numbersAndPunctuation)
            }
        }
        
        /// Button to start the workout split
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
