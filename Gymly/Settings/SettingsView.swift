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
    @State private var height: Double?
    @State private var weight: Double?
    @State private var bmi: Double?
    @State var bmiStatus: String = ""
    @State var bmiColor: Color = .green
    @State private var age: Int?
    @State private var editUser: Bool = false
    @State private var profileImage: UIImage?
    @State var selectedUnit:String = ""
    let units: [String] = ["Kg","Lbs"]
    
    var body: some View {
        NavigationView {
            List {
                    Button(action: {
                        editUser = true
                    }) {
                        ZStack {
                            LinearGradient(
                                gradient: Gradient(colors: [.red, .pink]),
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
                                            Text(config.userEmail)
                                        }
                                    }
                                    .foregroundStyle(Color.white)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .listRowBackground(Color.clear)
                    .frame(width: 340, height: 120)
                    .listRowSeparator(.hidden)
                if let weight = weight,
                   let bmi = bmi {
                    HStack {
                            HStack(spacing: 16) {
                                SettingUserInfoCell(
                                    value: String(format: "%.1f", weight),
                                    metric: config.weightUnit,
                                    headerColor: .gray,
                                    additionalInfo: "Body weight",
                                    icon: "figure.run"
                                )
                                SettingUserInfoCell(
                                    value: String(format: "%.1f", bmi),
                                    metric: "BMI",
                                    headerColor: bmiColor.opacity(0.9),
                                    additionalInfo: bmiStatus,
                                    icon: "figure.run"
                                )
//                                SettingUserInfoCell(
//                                    value: String(format: "%.2f", height),
//                                    metric: "M",
//                                    headerColor: .green,
//                                    additionalInfo: "Height",
//                                    icon: "figure.wave"
//                                )
//                                SettingUserInfoCell(
//                                    value: String(format: "%.0f", Double(age)),
//                                    metric: "YO",
//                                    headerColor: .green,
//                                    additionalInfo: "Age",
//                                    icon: "person.text.rectangle"
//                                )
                            }
                        
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
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
                            }
                        }
                        .frame(width: 300)
                        NavigationLink(destination: ConnectionsView(viewModel: viewModel)) {
                            Image(systemName: "square.2.layers.3d.top.filled")
                            Text("App connections")
                        }
                        .frame(width: 300)
                    }
                    Section(header: HStack {
                        Text("Graph")
                    }) {
                        ZStack {
                            ContentViewGraph()
                            RadarLabels()
                        }
                        .frame(width: 300, height: 300)
                    }
                    .listRowBackground(Color.clear)
                    .padding(.horizontal)
                }
                .navigationTitle("My profile")
                .onAppear() {
                    if let imagePath = config.userProfileImageURL {
                        profileImage = viewModel.loadImage(from: imagePath)
                    }
                    healthKitManager.fetchHeight { height in self.height = height }
                    healthKitManager.fetchWeight { weight in self.weight = weight }
                    healthKitManager.fetchBMI { bmi in
                        self.bmi = bmi
                        let (color, status) = getBmiStyle(bmi: bmi ?? 0.0)
                        self.bmiColor = color
                        self.bmiStatus = status
                    }
                    healthKitManager.fetchAge { age in self.age = age
                    }
                }
                .sheet(isPresented: $editUser, onDismiss: {
                    if let imagePath = config.userProfileImageURL {
                        profileImage = viewModel.loadImage(from: imagePath)
                    }
                }) {
                    EditUserView(viewModel: viewModel)
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
