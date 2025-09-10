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
    @Environment(\.colorScheme) private var scheme

    @State var bodyWeight: String = ""
    var body: some View {
        NavigationView {
            ZStack {
                FloatingClouds(theme: CloudsTheme.graphite(scheme))
                    .ignoresSafeArea()
                List {
                    Section("Body weight") {
                        HStack {
                            Text("Body weight (\(config.weightUnit))")
                                .foregroundStyle(.white.opacity(0.6))
                            TextField("70 \(config.weightUnit)", text: $bodyWeight)
                                .padding(.horizontal)
                                .keyboardType(.numbersAndPunctuation)
                                .onSubmit {
                                    healthKitManager.saveWeight(Double(bodyWeight) ?? 0.0)
                                    config.userWeight = (Double(bodyWeight) ?? 0.0)
                                    healthKitManager.updateFromWeightChart(context: context)
                                }
                        }
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .listRowBackground(Color.black.opacity(0.1))
                    }
                    Section("Weight progress") {
                        HStack {
                            Spacer()
                            WeightChart()
                            Spacer()
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .listRowBackground(Color.black.opacity(0.1))
                    Section("") {
                        Button("Back") {
                            healthKitManager.saveWeight(Double(bodyWeight) ?? 0.0)
                            config.userWeight = (Double(bodyWeight) ?? 0.0)
                            dismiss()
                        }
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .listRowBackground(Color.black.opacity(0.1))
                    }
                }
                .navigationTitle("My weight")
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .listRowBackground(Color.clear)
            }
        }
        .onAppear {
            bodyWeight = String(Int(round(Double(config.userWeight) * (config.weightUnit == "Kg" ? 1.0 : 2.20462))))
        }
    }
}

