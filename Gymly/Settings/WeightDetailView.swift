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
    @EnvironmentObject var userProfileManager: UserProfileManager
    @Environment(\.dismiss) var dismiss
    @StateObject var healthKitManager = HealthKitManager()
    @Environment(\.modelContext) var context: ModelContext
    @Environment(\.colorScheme) private var scheme

    @State var bodyWeight: String = ""
    @State private var showingSaveSuccess = false
    @State private var saveMessage = ""


    var body: some View {
        NavigationView {
            ZStack {
                FloatingClouds(theme: CloudsTheme.graphite(scheme))
                    .ignoresSafeArea()
                List {
                    Section("Body weight") {
                        HStack {
                            Text("Body weight (\(userProfileManager.currentProfile?.weightUnit ?? "Kg"))")
                                .foregroundStyle(.white.opacity(0.6))
                            TextField("70 \(userProfileManager.currentProfile?.weightUnit ?? "Kg")", text: $bodyWeight)
                                .padding(.horizontal)
                                .keyboardType(.numbersAndPunctuation)
                                .onSubmit {
                                    saveWeight()
                                }
                        }
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .listRowBackground(Color.black.opacity(0.1))

                        if showingSaveSuccess {
                            Text(saveMessage)
                                .foregroundColor(.green)
                                .font(.caption)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                                .listRowBackground(Color.black.opacity(0.1))
                        }
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
                            saveWeight()
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
            let currentWeight = userProfileManager.currentProfile?.weight ?? 0.0
            bodyWeight = String(Int(round(currentWeight * (userProfileManager.currentProfile?.weightUnit ?? "Kg" == "Kg" ? 1.0 : 2.20462))))
        }
    }
    
    private func saveWeight() {
        guard let inputWeight = Double(bodyWeight), inputWeight > 0 else {
            print("❌ Invalid weight input: \(bodyWeight)")
            return
        }

        // Convert input weight to kg (HealthKit always stores in kg)
        let weightInKg: Double
        if userProfileManager.currentProfile?.weightUnit ?? "Kg" == "Kg" {
            weightInKg = inputWeight
        } else {
            // Convert from lbs to kg
            weightInKg = inputWeight / 2.20462262
        }

        print("💾 Saving weight: \(inputWeight) \(userProfileManager.currentProfile?.weightUnit ?? "Kg") = \(weightInKg) kg")

        // Save to HealthKit (always in kg)
        healthKitManager.saveWeight(weightInKg)

        // Update user profile (always store in kg internally)
        userProfileManager.updatePhysicalStats(weight: weightInKg)

        // Show success message
        saveMessage = "Weight saved: \(inputWeight) \(userProfileManager.currentProfile?.weightUnit ?? "Kg")"
        showingSaveSuccess = true

        // Hide success message after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showingSaveSuccess = false
        }

        // Refresh weight chart data
        healthKitManager.updateFromWeightChart(context: context)
    }
}



