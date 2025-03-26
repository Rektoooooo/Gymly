//
//  WeightDetailView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 26.03.2025.
//

import SwiftUI

struct WeightDetailView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @EnvironmentObject var config: Config
    @Environment(\.dismiss) var dismiss
    @StateObject var healthKitManager = HealthKitManager()
    @State var bodyWeight: String = ""
    var body: some View {
        NavigationView {
            List {
                Section("Body weight") {
                    HStack {
                        Text("Body weight")
                            .foregroundStyle(.white.opacity(0.6))
                        TextField("70 \(config.weightUnit)", text: $bodyWeight)
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .keyboardType(.numbersAndPunctuation)
                    }
                }
                Section("") {
                    Button("Save changes") {
                        healthKitManager.saveWeight(Double(bodyWeight) ?? 0.0)
                        config.userWeight = (Double(bodyWeight) ?? 0.0)
                        dismiss()
                    }
                }
            }
            .navigationTitle("My weight")
        }
        .onAppear {
            bodyWeight = config.userWeight.description
        }
    }
}

