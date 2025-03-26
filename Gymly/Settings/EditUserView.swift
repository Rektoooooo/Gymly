//
//  EditUserView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 29.01.2025.
//

import SwiftUI
import PhotosUI

struct EditUserView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @State private var avatarItem: PhotosPickerItem?
    @State private var avatarImage: UIImage?
    @EnvironmentObject var config: Config
    @Environment(\.dismiss) var dismiss
    @State private var profileImage: UIImage?
    @StateObject var healthKitManager = HealthKitManager()
    
    var body: some View {
        NavigationView {
            List {
                Section("Profile image") {
                    HStack {
                        Spacer()
                        if avatarImage == nil {
                            ProfileImageCell(profileImage: profileImage, frameSize: 100)
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
                            let savedPath = viewModel.saveImageToDocuments(image: image)
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
                    profileImage = viewModel.loadImage(from: imagePath)
                }
            }
        }
    }
}
