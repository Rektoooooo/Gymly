//
//  SetupSplitView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 17.10.2024.
//

import SwiftUI

struct SetupSplitView: View {
    @State private var editPlan: Bool = false
    @State private var splitLength: String = ""
    @State private var splitDay: String = ""
    @State private var weekDays:[String] = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @EnvironmentObject var config: Config
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
        Button("Set up individual day") {
            for i in 0...(Int(splitLength) ?? 1) - 1 {
                addDay(name: "Day \(i + 1)", index: i + 1)
            }
            do {
                try context.save()
                debugPrint("Context saved")
            } catch {
                debugPrint(error)
            }
            config.splitStarted = true
            config.dayInSplit = Int(splitDay) ?? 1
            dismiss()
            editPlan.toggle()
        }
        .padding()
        .background(Color.graytint)
        .cornerRadius(20)
        .padding()
        .sheet(isPresented: $editPlan, onDismiss: {
        }) {
            SplitView()
        }
    }
    
    func addDay(name: String, index:Int) {
        context.insert(Day(name: name,dayOfSplit: index, exercises: [],date: ""))
        debugPrint("Added day \(name)")
    }
    
}

#Preview {
    SetupSplitView()
}
