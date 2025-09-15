//
//  AccountView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 13.05.2024.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @EnvironmentObject var config: Config
    @Environment(\.dismiss) var dismiss
    @StateObject var healthKitManager = HealthKitManager()
    @Environment(\.modelContext) var context: ModelContext
    @Environment(\.colorScheme) private var scheme
    @State private var height: Double?
    @State private var weight: Double?
    @State private var bmi: Double?
    @State var bmiStatus: String = ""
    @State var bmiColor: Color = .green
    @State private var age: Int?
    @State private var editUser: Bool = false
    @State private var showBmiDetail: Bool = false
    @State private var showWeightDetail: Bool = false
    @State private var profileImage: UIImage?
    @State var selectedUnit:String = ""
    @State private var weightUpdatedTrigger = false
    
    
    let units: [String] = ["Kg","Lbs"]
    
    @State var graphSorting: [String] = ["Today","Week","Month","All Time"]
    @State var graphSortingSelected: String = "Today"
    private var selectedTimeRange: ContentViewGraph.TimeRange {
        switch graphSortingSelected {
        case "Today": return .day
        case "Week": return .week
        case "Month": return .month
        case "All Time": return .all
        default: return .month
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                FloatingClouds(theme: CloudsTheme.red(scheme))
                    .ignoresSafeArea()
                List {
                    Button(action: {
                        editUser = true
                    }) {
                        ZStack {
                            LinearGradient(
                                gradient: Gradient(colors: [.accent, .accent]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .cornerRadius(20)
                            HStack {
                                HStack {
                                    ProfileImageCell(profileImage: profileImage, frameSize: 80)
                                        .padding()
                                    VStack {
                                        VStack {
                                            Text("\(config.username)")
                                                .multilineTextAlignment(.leading)
                                                .bold()
                                                .padding(2)
                                        }
                                        HStack {
                                            HStack {
                                                Image(systemName: "flame")
                                                Text("100 streaks")
                                            }
                                            .font(.footnote)
                                            .bold()
                                            HStack {
                                                Image(systemName: "clock")
                                                Text("1357 h")
                                            }
                                            .font(.footnote)
                                            .bold()
                                        }
                                    }
                                    .foregroundStyle(Color.black)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .listRowBackground(Color.clear)
                    .frame(width: 340, height: 120)
                    .listRowSeparator(.hidden)
                    HStack {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                Button(action: {
                                    showWeightDetail = true
                                }) {
                                    SettingUserInfoCell(
                                        value: String(
                                            format: "%.1f",
                                            config.userWeight * (config.weightUnit == "Kg" ? 1.0 : 2.20462262)),
                                        metric: config.weightUnit,
                                        headerColor: .accent,
                                        additionalInfo: "Body weight",
                                        icon: "figure.mixed.cardio"
                                    )
                                }
                                .foregroundStyle(Color.white)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                Button(action: {
                                    showBmiDetail = true
                                }) {
                                    SettingUserInfoCell(
                                        value: String(format: "%.1f", config.userBMI),
                                        metric: "BMI",
                                        headerColor: bmiColor,
                                        additionalInfo: bmiStatus,
                                        icon: "dumbbell.fill"
                                    )
                                }
                                .foregroundStyle(Color.white)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                SettingUserInfoCell(
                                    value: String(format: "%.2f", config.userHeight),
                                    metric: "m",
                                    headerColor: .accent,
                                    additionalInfo: "Height",
                                    icon: "figure.wave"
                                )
                                SettingUserInfoCell(
                                    value: String(format: "%.0f", Double(config.userAge)),
                                    metric: "yo",
                                    headerColor: .accent,
                                    additionalInfo: "Age",
                                    icon: "person.text.rectangle"
                                )
                            }
                        }
                    }
                    .frame(width: 370)
                    .padding(.horizontal, 4)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .id(weightUpdatedTrigger)
                    Section("Preferences") {
                        HStack {
                            HStack {
                                Image(systemName: "scalemass")
                                Text("Unit")
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Picker(selection: $config.weightUnit, label: Text("")) {
                                ForEach(units, id: \.self) { unit in
                                    Text(unit)
                                }
                            }
                            .pickerStyle(.segmented)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing, -30)
                            .onChange(of: config.weightUnit) {
                                debugPrint("Selected unit: \(config.weightUnit)")
                                config.roundSetWeights = true
                                weightUpdatedTrigger.toggle()
                            }
                        }
                        .frame(width: 300)
                        NavigationLink(destination: ConnectionsView(viewModel: viewModel)) {
                            Image(systemName: "square.2.layers.3d.top.filled")
                            Text("App connections")
                        }
                        .frame(width: 300)
                    }
                    .listRowBackground(Color.black.opacity(0.05))
                    Section(header: HStack {
                        Text("Graph")
                    }) {
                        VStack(spacing: 8) {
                            Picker(selection: $graphSortingSelected, label: Text("")) {
                                ForEach(graphSorting, id: \.self) { option in
                                    Text(option).tag(option)
                                }
                            }
                            .pickerStyle(.segmented)
                            
                            ZStack {
                                ContentViewGraph(range: selectedTimeRange)
                                RadarLabels()
                            }
                            .frame(width: 300, height: 300)
                        }
                    }
                    .listRowBackground(Color.clear)
                    .padding(.horizontal)
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .navigationTitle("\(config.username)'s profile")
                .onAppear {
                    if let imagePath = config.userProfileImageURL {
                        profileImage = viewModel.loadImage(from: imagePath)
                    }
                    healthKitManager.fetchHeight { height in
                        DispatchQueue.main.async {
                            config.userHeight = height ?? 0.0
                        }
                    }
                    healthKitManager.fetchWeight { weight in
                        DispatchQueue.main.async {
                            config.userWeight = weight ?? 0.0
                        }
                    }
                    healthKitManager.fetchAge { age in
                        DispatchQueue.main.async {
                            config.userAge = age ?? 0
                        }
                    }
                    
                    config.userBMI = config.userWeight / (config.userHeight * config.userHeight)
                    let (color, status) = getBmiStyle(bmi: config.userBMI)
                    bmiColor = color
                    bmiStatus = status
                    
                    healthKitManager.updateFromWeightChart(context: context)
                }
                .sheet(isPresented: $editUser, onDismiss: {
                    if let imagePath = config.userProfileImageURL {
                        profileImage = viewModel.loadImage(from: imagePath)
                    }
                    healthKitManager.fetchWeight { weight in
                        DispatchQueue.main.async {
                            config.userWeight = weight ?? 0.0
                        }
                    }                }) {
                        EditUserView(viewModel: viewModel)
                    }
                    .sheet(isPresented: $showBmiDetail, onDismiss: {
                    }) {
                        let (color, status) = getBmiStyle(bmi: config.userBMI)
                        BmiDetailView(viewModel: viewModel, bmiColor: color, bmiText: status)
                    }
                    .sheet(isPresented: $showWeightDetail, onDismiss: {
                        healthKitManager.fetchWeight { weight in
                            DispatchQueue.main.async {
                                healthKitManager.updateFromWeightChart(context: context)
                                config.userWeight = weight ?? config.userWeight
                                config.userBMI = config.userWeight / (config.userHeight * config.userHeight)
                                weightUpdatedTrigger.toggle() // Trigger UI update
                            }
                        }                }) {
                            WeightDetailView(viewModel: viewModel)
                        }
            }
        }
    }
}

func getBmiStyle(bmi: Double) -> (Color, String) {
    switch bmi {
    case ..<18.5:
        return (.orange, "Underweight")
    case 18.5...24.9:
        return (.green, "Normal weight")
    case 25...29.9:
        return (.orange, "Overweight")
    default:
        return (.red, "Obese")
    }
}


