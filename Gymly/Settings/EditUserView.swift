//
//  EditUserView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 29.01.2025.
//

import SwiftUI
import PhotosUI

struct EditUserView: View {
    
    @State private var avatarItem: PhotosPickerItem?
    @State private var avatarImage: UIImage?
    @EnvironmentObject var config: Config
    @Environment(\.dismiss) var dismiss
    @State private var profileImage: UIImage?
    
    var body: some View {
        NavigationView {
            List {
                Section("Profile image") {
                    HStack {
                        Spacer()
                        if avatarImage == nil {
                            if let image = profileImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .padding()
                            } else {
                                Image("defaultProfileImage")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .shadow(color: Color.black.opacity(0.6), radius: 15, x: 0, y: 0)
                                    .padding()
                            }
                        } else {
                            if let avatarImage = avatarImage {
                                Image(uiImage: avatarImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .padding()
                                    .shadow(color: Color.black.opacity(0.6), radius: 15, x: 0, y: 0)
                            }
                        }
                        Spacer()
                    }
                    PhotosPicker("Select avatar", selection: $avatarItem, matching: .images)
                        .onChange(of: avatarItem) {
                            Task {
                                if let newItem = avatarItem,
                                   let data = try? await newItem.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    avatarImage = uiImage
                                }
                            }
                        }
                }
                Section("User credencials") {
                    HStack {
                        Text("Username")
                            .foregroundStyle(.white.opacity(0.6))
                        TextField("Username", text: $config.username)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                }

                Section("") {
                    Button("Save changes") {
                        if let image = avatarImage {
                            let savedPath = saveImageToDocuments(image: image)
                            config.userProfileImageURL = savedPath // Update the config
                            debugPrint(config.userProfileImageURL!)
                        }
                        dismiss()
                    }
                }
            }
            .navigationTitle("Edit profile")
            .onAppear() {
                if let imagePath = config.userProfileImageURL {
                    profileImage = loadImage(from: imagePath)
                }
            }
        }
    }
    
    /// Saves the UIImage to the Documents directory
    func saveImageToDocuments(image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        
        let filename = "profile_picture.jpg"
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
        
        do {
            try data.write(to: fileURL)
            return fileURL.path
        } catch {
            print("❌ Error saving image: \(error)")
            return nil
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
}

