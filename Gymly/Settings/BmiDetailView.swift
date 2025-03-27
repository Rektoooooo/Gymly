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
    @State var bodyWeight: String = ""
    @State var bmi: Double = 0.0
    @State var bmiRangeLow:Double = 0.0
    @State var bmiRangeHigh:Double = 0.0
    @State var bmiColor: Color = .green
    @State var bmiText: String = "Normal weight"
    
    var body: some View {
        NavigationView {
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
                                TextField("70 \(config.weightUnit)", text: $bodyWeight)
                                    .padding(.horizontal)
                                    .keyboardType(.numbersAndPunctuation)
                                    .offset(x: -10)
                                    .onSubmit {
                                        if let weight = Double(bodyWeight) {
                                            let heightSquared = config.userHeight * config.userHeight
                                            bmi = weight / heightSquared
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
                                let minWeight = config.userHeight * config.userHeight * bmiRangeLow
                                let maxWeight = config.userHeight * config.userHeight * bmiRangeHigh
                                let formattedMin = String(format: "%.1f", minWeight)
                                let formattedMax = String(format: "%.1f", maxWeight)
                                if Double(formattedMax) ?? 0.0 > 102.7 {
                                    Text("\(formattedMin)+ \(config.weightUnit)")
                                        .foregroundStyle(bmiColor)
                                } else {
                                    Text("\(formattedMin) - \(formattedMax) \(config.weightUnit)")
                                        .foregroundStyle(bmiColor)
                                }
                                
                            }
                        }
                    }
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
                }
                Section("") {
                    Button("Back") {
                        dismiss()
                    }
                }
            }
            .onAppear() {
                config.userBMI = config.userWeight / (config.userHeight * config.userHeight)
                bmi = config.userWeight / (config.userHeight * config.userHeight)
                bodyWeight = String(format: "%.1f", config.userWeight)
                changeRange()
            }
            .navigationTitle("BMI Calculator")
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
