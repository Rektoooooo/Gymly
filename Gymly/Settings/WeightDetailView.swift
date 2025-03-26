//
//  WeightDetailView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 26.03.2025.
//

import SwiftUI
import SwiftData

struct WeightDetailView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @EnvironmentObject var config: Config
    @Environment(\.dismiss) var dismiss
    @StateObject var healthKitManager = HealthKitManager()
    @Environment(\.modelContext) var context: ModelContext
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
                            .onSubmit {
                                healthKitManager.saveWeight(Double(bodyWeight) ?? 0.0)
                                config.userWeight = (Double(bodyWeight) ?? 0.0)
                                healthKitManager.updateFromWeightChart(context: context)
                            }
                    }
                }
                Section("Weight progress") {
                    HStack {
                        Spacer()
                        WeightChart()
                        Spacer()
                    }
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                Section("") {
                    Button("Back") {
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

