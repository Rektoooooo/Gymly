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
    let bmiColor: Color
    let bmiText: String
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
                            Text("Body weight \(bodyWeight) \(config.weightUnit)")
                            Spacer()
                            let minWeight = config.userHeight * config.userHeight * 18.5
                            let maxWeight = config.userHeight * config.userHeight * 24.9
                            let formattedMin = String(format: "%.1f", minWeight)
                            let formattedMax = String(format: "%.1f", maxWeight)
                            Text("\(formattedMin) - \(formattedMax) \(config.weightUnit)")
                                .foregroundStyle(bmiColor)
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
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .onAppear() {
                config.userBMI = config.userWeight / (config.userHeight * config.userHeight)
                bmi = config.userWeight / (config.userHeight * config.userHeight)
                bodyWeight = String(format: "%.1f", config.userWeight)
            }
            .navigationTitle("My BMI")
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
