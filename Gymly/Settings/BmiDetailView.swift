//
//  WeightAndBmiDetailView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 26.03.2025.
//

import SwiftUI

struct BmiDetailView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @EnvironmentObject var config: Config
    @Environment(\.dismiss) var dismiss
    @StateObject var healthKitManager = HealthKitManager()
    @EnvironmentObject var userProfileManager: UserProfileManager
    @Environment(\.colorScheme) private var scheme
    @State var bodyWeight: String = ""
    @State var bmi: Double = 0.0
    @State var bmiRangeLow:Double = 0.0
    @State var bmiRangeHigh:Double = 0.0
    @State var bmiColor: Color = .green
    @State var bmiText: String = "Normal weight"

    // Computed properties to break down complex expressions
    private var currentHeight: Double {
        userProfileManager.currentProfile?.height ?? 0.0
    }

    private var currentWeight: Double {
        userProfileManager.currentProfile?.weight ?? 0.0
    }

    private var weightUnit: String {
        userProfileManager.currentProfile?.weightUnit ?? "Kg"
    }

    private var isKgUnit: Bool {
        weightUnit == "Kg"
    }

    private var weightConversionFactor: Double {
        isKgUnit ? 1.0 : 2.20462
    }

    private var maxWeightThreshold: Double {
        isKgUnit ? 102.7 : 226.4
    }

    var body: some View {
        NavigationView {
            ZStack {
                switch bmiColor {
                case .green: FloatingClouds(theme: CloudsTheme.green(scheme))
                        .ignoresSafeArea()
                case .orange: FloatingClouds(theme: CloudsTheme.orange(scheme))
                        .ignoresSafeArea()
                case .red: FloatingClouds(theme: CloudsTheme.red(scheme))
                        .ignoresSafeArea()
                default:
                    FloatingClouds(theme: CloudsTheme.green(scheme))
                        .ignoresSafeArea()
                }
                List {
                    Section("") {
                        BMIGaugeView(bmi: bmi, bmiColor: bmiColor, bmiText: bmiText)
                            .padding()
                            .background(Color.clear)
                            .edgesIgnoringSafeArea(.all)
                            .padding(.top, -20)
                            .frame(height: 150)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    Section("Category range") {
                        VStack {
                            HStack {
                                HStack {
                                    Text("Body weight :")
                                        .foregroundStyle(.white.opacity(0.6))
                                        .frame(width: 110)
                                    TextField("70 \(weightUnit)", text: $bodyWeight)
                                        .padding(.horizontal)
                                        .keyboardType(.numbersAndPunctuation)
                                        .offset(x: -10)
                                        .onSubmit {
                                            if let weight = Double(bodyWeight) {
                                                // Convert weight to kg if needed for BMI calculation
                                                let weightInKg = isKgUnit ? weight : weight / 2.20462
                                                let heightSquared = (userProfileManager.currentProfile?.height ?? 0.0) * (userProfileManager.currentProfile?.height ?? 0.0)
                                                bmi = weightInKg / heightSquared
                                                let (color, status) = getBmiStyle(bmi: bmi)
                                                bmiColor = color
                                                bmiText = status
                                                changeRange()
                                            } else {
                                                // Handle invalid input
                                                bmi = 0.0
                                            }
                                        }
                                }
                                Spacer()
                                HStack {
                                    let heightSquared = currentHeight / 100.0 * currentHeight / 100.0
                                    let minWeightKg = heightSquared * bmiRangeLow
                                    let maxWeightKg = heightSquared * bmiRangeHigh

                                    // Convert to display units
                                    let minWeight = minWeightKg * weightConversionFactor
                                    let maxWeight = maxWeightKg * weightConversionFactor
                                    let formattedMin = String(format: "%.1f", minWeight)
                                    let formattedMax = String(format: "%.1f", maxWeight)

                                    if maxWeight > maxWeightThreshold {
                                        Text("\(formattedMin)+ \(weightUnit)")
                                            .foregroundStyle(bmiColor)
                                    } else {
                                        Text("\(formattedMin) - \(formattedMax) \(weightUnit)")
                                            .foregroundStyle(bmiColor)
                                    }
                                }
                            }
                        }
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .listRowBackground(Color.black.opacity(0.1))
                    }
                    Section("Category") {
                        ForEach(bmiCategories) { category in
                            HStack {
                                let isActive = category.range.contains(bmi)
                                
                                Text(category.title)
                                    .bold(isActive)
                                    .foregroundStyle(isActive ? category.color : .primary)
                                
                                Spacer()
                                
                                Text(category.rangeText)
                                    .bold(isActive)
                                    .foregroundStyle(isActive ? category.color : .primary)
                            }
                        }
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .listRowBackground(Color.black.opacity(0.1))
                    }
                    Section("") {
                        Button("Back") {
                            dismiss()
                        }
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .listRowBackground(Color.black.opacity(0.1))
                    }
                }
                .onAppear() {
                    // Get BMI from profile (it's calculated correctly there)
                    bmi = userProfileManager.currentProfile?.bmi ?? 0.0

                    // Display weight in the user's preferred unit
                    let displayWeight = currentWeight * weightConversionFactor
                    bodyWeight = String(format: "%.1f", displayWeight)
                    changeRange()
                }
                .navigationTitle("BMI Calculator")
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .listRowBackground(Color.clear)
            }
        }
    }
    
    func changeRange() {
        switch bmiText {
            case "Underweight":
            bmiRangeLow = 0.0
            bmiRangeHigh = 18.5
        case "Normal weight":
            bmiRangeLow = 18.5
            bmiRangeHigh = 24.9
        case "Overweight":
            bmiRangeLow = 25.0
            bmiRangeHigh = 29.9
        case "Obese":
            bmiRangeLow = 30.0
            bmiRangeHigh = 100.0
        default:
            bmiRangeLow = 0.0
            bmiRangeHigh = 0.0
        }
    }
}


struct BMICategory: Identifiable {
    let id = UUID()
    let title: String
    let range: ClosedRange<Double>
    let rangeText: String
    let color: Color
}

let bmiCategories: [BMICategory] = [
    BMICategory(title: "Underweight", range: 0.0...18.5, rangeText: "≤ 18.5", color: .orange),
    BMICategory(title: "Normal weight", range: 18.5...24.9, rangeText: "18.5 - 24.9", color: .green),
    BMICategory(title: "Overweight", range: 25.0...29.9, rangeText: "25.0 - 29.9", color: .orange),
    BMICategory(title: "Obese", range: 30.0...100.0, rangeText: "≥ 30.0", color: .red)
]
