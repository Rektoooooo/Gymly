//
//  AccountView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 13.05.2024.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    
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
                                if let image = profileImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(Circle())
                                        .shadow(color: Color.black.opacity(0.6), radius: 15, x: 0, y: 0)
                                        .padding()
                                } else {
                                    Image("defaultProfileImage")
                                        .resizable()
                                        .frame(width: 80, height: 80)
                                        .clipShape(Circle())
                                        .shadow(color: Color.black.opacity(0.6), radius: 15, x: 0, y: 0)
                                        .padding()
                                }
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
                        Image(systemName: "scalemass")
                        Text("Unit")
                        Picker(selection: $config.weightUnit, label: Label("Unit", systemImage: "scalemass.fill")) {
                            ForEach(units, id: \.self) { unit in
                                Text(unit)
                            }
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: config.weightUnit) { newValue in
                            debugPrint("Selected unit: \(newValue)")
                            config.roundSetWeights = true
                        }
                    }
                    .frame(width: 300)
                    NavigationLink(destination: ConnectionsView()) {
                        Image(systemName: "square.2.layers.3d.top.filled")
                        Text("App connections")
                    }
                    .frame(width: 300)
                }
                Section("Graph") {
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        editUser = true
                    } label: {
                        Label("", systemImage: "square.and.pencil")
                    }
                }
                
            }
            .onAppear() {
                if let imagePath = config.userProfileImageURL {
                    profileImage = loadImage(from: imagePath)
                }
                healthKitManager.fetchHeight { height in self.height = height }
                healthKitManager.fetchWeight { weight in self.weight = weight }
                healthKitManager.fetchAge { age in self.age = age }
            }
            .sheet(isPresented: $editUser, onDismiss: {
                if let imagePath = config.userProfileImageURL {
                    profileImage = loadImage(from: imagePath)
                }
            }) {
                EditUserView()
            }
        }
    }
    func loadImage(from path: String) -> UIImage? {
        let fileURL = URL(fileURLWithPath: path)
        guard FileManager.default.fileExists(atPath: fileURL.path),
              let imageData = try? Data(contentsOf: fileURL),
              let uiImage = UIImage(data: imageData) else {
            return nil
        }
        return uiImage
    }
    
    @ViewBuilder
    func DefaultProfileImage() -> some View {
        Image("defaultProfileImage")
            .resizable()
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            .padding()
            .shadow(color: Color.black.opacity(0.6), radius: 15, x: 0, y: 0)
    }
}
