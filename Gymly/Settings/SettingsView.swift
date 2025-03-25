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
    @State private var age: Int?
    @State private var editUser: Bool = false
    @State private var profileImage: UIImage?
    @State var selectedUnit:String = ""
    let units: [String] = ["Kg","Lbs"]
    
    var body: some View {
        NavigationView {
            List {
                Section("") {
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
                                            .padding()
                                    }
                                    HStack {
                                        Spacer()
                                        VStack() {
                                            Text(weight != nil ? "\(String(format: "%.1f", weight!)) kg" : "nil")
                                                .bold()
                                            Text("weight")
                                                .font(.caption)
                                        }
                                        Spacer()
                                        VStack() {
                                            Text("\(height != nil ? "\(height!) m" : "nil")")
                                                .bold()
                                            Text("height")
                                                .font(.caption)
                                        }
                                        Spacer()
                                        VStack() {
                                            Text("\(age != nil ? "\(age!)" : "nil")")
                                                .bold()
                                            Text("age")
                                                .font(.caption)
                                        }
                                        Spacer()
                                    }
                                }
                                Spacer()
                            }
                        }
                    }
                    .listRowBackground(Color.clear)
                    .frame(width: 340, height: 120)
                    HStack {
                        VStack {
                            ZStack {
                                LinearGradient(
                                    gradient: Gradient(colors: [.red, .orange]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                Image(systemName: "flame")
                            }
                            .frame(width: 70, height: 70, alignment: .leading)
                            .cornerRadius(25)
                            Text("5")
                                .bold()
                            Text("Streak")
                                .font(.caption)
                        }
                        Spacer()
                        VStack {
                            ZStack {
                                LinearGradient(
                                    gradient: Gradient(colors: [.orange, .yellow]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                Image(systemName: "clock")
                            }
                            .frame(width: 70, height: 70, alignment: .leading)
                            .cornerRadius(25)
                            Text("1453h")
                                .bold()
                            Text("working out")
                                .font(.caption)
                        }
                        Spacer()
                        VStack {
                            ZStack {
                                LinearGradient(
                                    gradient: Gradient(colors: [.yellow, .red]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                Image(systemName: "medal")
                            }
                            .frame(width: 70, height: 70, alignment: .leading)
                            .cornerRadius(25)
                            Text("12")
                                .bold()
                            Text("Medals")
                                .font(.caption)
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
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
                    Text("Data: \(config.graphDataValues.description)")
                        .foregroundColor(.white)
                    Text("Max Value: \(config.graphMaxValue.description)")
                        .foregroundColor(.white)

                    ZStack {
                        ContentViewGraph()
                        RadarLabels()
                    }
                    .frame(width: 300, height: 300)
                }
                .listRowBackground(Color.clear)
                .padding(.horizontal)
            }
            .scrollIndicators(.hidden)
            .navigationTitle("My profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        editUser = true
                    } label: {
                        HStack {
                            Text("Edit")
                            Image(systemName: "person.crop.circle")
                        }
                    }
                }
                
            }
            .onAppear() {
                if let imagePath = config.userProfileImageURL {
                    profileImage = viewModel.loadImage(from: imagePath)
                }
                healthKitManager.fetchHeight { height in self.height = height }
                healthKitManager.fetchWeight { weight in self.weight = weight }
                healthKitManager.fetchAge { age in self.age = age }
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
