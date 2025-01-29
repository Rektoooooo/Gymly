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
    @State private var avatarImage: Image?
    @EnvironmentObject var config: Config
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            HStack {
                Spacer()
                TextField("Username", text: $config.username)
                Spacer()
            }
            VStack {
                PhotosPicker("Select avatar", selection: $avatarItem, matching: .images)
                avatarImage?
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
                    .padding()
                    .shadow(color: Color.black.opacity(0.6), radius: 15, x: 0, y: 0)
            }
            .padding()
            .onChange(of: avatarItem) {
                Task {
                    if let loaded = try? await avatarItem?.loadTransferable(type: Image.self) {
                        avatarImage = loaded
                    } else {
                        print("Failed")
                    }
                }
            }
        }
        Button("Save changes") {
            if let uiImage = avatarImage!.asUIImage() { // Convert SwiftUI Image to UIImage
                if let savedPath = saveImageToDocuments(image: uiImage) {
                    config.userProfileImageURL = savedPath
                    debugPrint("Saved image path \(savedPath)")
                }
            }
            dismiss()
        }
        .padding()
    }
    
    
    func saveImageToDocuments(image: UIImage, filename: String = "profile.jpg") -> String? {
        let fileURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)

        print("💾 Saving image to: \(fileURL.path)")

        if let imageData = image.jpegData(compressionQuality: 0.8) {
            do {
                try imageData.write(to: fileURL)
                print("✅ Image saved successfully!")
                return fileURL.absoluteString
            } catch {
                print("❌ Error saving image: \(error)")
            }
        } else {
            print("❌ Failed to convert UIImage to Data")
        }
        return nil
    }
    
}

#Preview {
    EditUserView()
}
