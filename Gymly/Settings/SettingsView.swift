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
                            if let imagePath = config.userProfileImageURL {
                                if imagePath == "defaultProfileImage" {
                                    Image("defaultProfileImage") // Load from Assets
                                        .resizable()
                                        .frame(width: 80, height: 80)
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
                                            .frame(width: 80, height: 80)
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle().stroke(Color.white, lineWidth: 2)
                                            )
                                            .padding()
                                    } else {
                                        Image("defaultProfileImage")  // Default system placeholder
                                            .resizable()
                                            .frame(width: 80, height: 80)
                                            .clipShape(Circle())
                                            .shadow(color: Color.black.opacity(0.6), radius: 15, x: 0, y: 0)
                                            .padding()
                                    }
                                }
                            }
                            VStack {
                                VStack {
                                    Text("\(config.username)")
                                        .multilineTextAlignment(.leading)
                                        .bold()
                                        .padding()
//                                    Text("\(config.userEmail)")
//                                        .multilineTextAlignment(.leading)
//                                        .font(.caption)
//                                        .padding()
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
                    .frame(width: 320)
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
                        .onChange(of: selectedUnit) {
                            debugPrint("Selected unit : \(selectedUnit)")
                            config.weightUnit = selectedUnit
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
                healthKitManager.fetchHeight { height in self.height = height }
                healthKitManager.fetchWeight { weight in self.weight = weight }
                healthKitManager.fetchAge { age in self.age = age }
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
    
    func loadImageFromUserDefaults() -> UIImage? {
        if let base64String = UserDefaults.standard.string(forKey: "userProfileImageBase64"),
           let imageData = Data(base64Encoded: base64String) {
            return UIImage(data: imageData)
        }
        return nil
    }
}



#Preview {
    SettingsView()
}
