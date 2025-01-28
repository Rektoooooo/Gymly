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

    @State var selectedUnit:String = ""
    let units: [String] = ["Kg","Lbs"]
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    if let imagePath = config.userProfileImageURL {
                        if imagePath == "defaultProfileImage" {
                            Image("defaultProfileImage") // Load from Assets
                                .resizable()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .padding()
                        } else if let uiImage = loadImageFromDocuments(filename: imagePath) {
                            Image(uiImage: uiImage) // Load user-selected image
                                .resizable()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(
                                    Circle().stroke(Color.white, lineWidth: 2)
                                )
                                .padding()
                        }
                    } else {
                        Image(systemName: "person.circle.fill") // Default if no image
                            .resizable()
                            .foregroundColor(.gray)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(Color.white, lineWidth: 2)
                            )
                            .padding()
                    }
                    VStack {
                        Text("Username")
                        Text("Gym streak : 0")
                    }
                    Spacer()
                }
                .background(Color.graytint)
                .cornerRadius(20)
                .shadow(radius: 5)
                .padding()
                HStack {
                    GeometryReader { geometry in
                        ContentView()
                            .frame(width: geometry.size.width, height: 250) // Fill available width
                            .scaledToFit()
                    }
                }
                .frame(height: 250) // Ensure `HStack` stays at 250 height
                .background(Color.gray.opacity(1))
                .cornerRadius(20)
                .shadow(radius: 5)
                .padding()
                List {
                    Section("App settings") {
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
                        HStack {
                            Text("\(config.lastUpdateDate)")
                        }
                        HStack {
                            Text("\(config.dayInSplit)")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .padding()
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
}

#Preview {
    SettingsView()
}
