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
    
    @State var selectedUnit:String = ""
    let units: [String] = ["Kg","Lbs"]
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [.black, .graytint]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                ScrollView {
                    VStack {
                        ZStack {
                            LinearGradient(
                                gradient: Gradient(colors: [.red, .pink]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            HStack {
                                if let imagePath = config.userProfileImageURL {
                                    if imagePath == "defaultProfileImage" {
                                        Image("defaultProfileImage") // Load from Assets
                                            .resizable()
                                            .frame(width: 100, height: 100)
                                            .clipShape(Circle())
                                            .shadow(color: Color.black.opacity(0.6), radius: 15, x: 0, y: 0)
                                            .padding()
                                    } else {
                                        let fileURL = URL(fileURLWithPath: imagePath.replacingOccurrences(of: "file://", with: "")) // Fix local file path
                                        
                                        if FileManager.default.fileExists(atPath: fileURL.path), // Ensure file exists
                                           let imageData = try? Data(contentsOf: fileURL), // Load Image Data
                                           let uiImage = UIImage(data: imageData) { // Convert to UIImage
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .frame(width: 100, height: 100)
                                                .clipShape(Circle())
                                                .overlay(
                                                    Circle().stroke(Color.white, lineWidth: 2)
                                                )
                                                .padding()
                                        } else {
                                            Image("defaultProfileImage")  // Default system placeholder
                                                .resizable()
                                                .frame(width: 100, height: 100)
                                                .clipShape(Circle())
                                                .shadow(color: Color.black.opacity(0.6), radius: 15, x: 0, y: 0)
                                                .padding()
                                        }
                                    }
                                }
                                VStack {
                                    Text("\(config.username)")
                                        .multilineTextAlignment(.leading)
                                        .bold()
                                        .padding()
                                    HStack {
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
                                    }
                                }
                                Spacer()
                            }
                        }
                        .frame(width: 350)
                        .background(Color.graytint)
                        .cornerRadius(20)
                        .padding()
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
                        .frame(width: 320)
                        VStack {
                            ZStack {
                                LinearGradient(
                                    gradient: Gradient(colors: [.yellow, .orange]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .cornerRadius(20)
                                VStack {
                                    Section("Preferences") {
                                        HStack {
                                            Text("Weight unit")
                                            Picker("Weight unit", selection: $config.weightUnit) {
                                                ForEach(units, id: \.self) { unit in
                                                    Text("\(unit)")
                                                }
                                            }
                                            .pickerStyle(.segmented)
                                            .onChange(of: selectedUnit) {
                                                debugPrint("Selected unit : \(selectedUnit)")
                                                config.weightUnit = selectedUnit
                                            }
                                        }
                                    }
                                    .bold()
                                }
                                .padding()
                            }
                        }
                        .frame(width: 350)
                        .padding()
                        VStack {
                            Button("Request HealthKit Access") {
                                healthKitManager.requestAuthorization()
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        VStack {
                            ZStack {
                                ContentViewGraph()
                                RadarLabels()
                            }
                            .padding()
                        }
                        .frame(width: 300, height: 300)
                        .padding(.vertical, 40)
                    }
                }
                .scrollIndicators(.hidden)
                .navigationTitle("My profile")
                .navigationBarTitleDisplayMode(.inline)
                .padding()
            }
            .onAppear() {
                healthKitManager.fetchHeight { height in self.height = height }
                healthKitManager.fetchWeight { weight in self.weight = weight }
                healthKitManager.fetchAge { age in self.age = age }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        editUser = true
                    } label: {
                        Label("", systemImage: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $editUser, onDismiss: {
                
            }) {
                EditUserView()
            }
        }
    }
    
    func loadImageFromDocuments(filename: String) -> UIImage? {
        let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
        if let imageData = try? Data(contentsOf: fileURL) {
            return UIImage(data: imageData)
        }
        return nil
    }
    
    func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    @ViewBuilder
    private func DefaultProfileImage() -> some View {
        Image("defaultProfileImage")
            .resizable()
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            .padding()
            .shadow(color: Color.black.opacity(0.6), radius: 15, x: 0, y: 0)
    }
}



#Preview {
    SettingsView()
}
