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
                    .padding()
                    .background(Color(.systemGray2))
                    .cornerRadius(10)
                    .padding(.horizontal)
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
            saveImageToUserDefaults(image: imageToUIImage(avatarImage!)!)
            dismiss()
        }
        .padding()
    }
    

    func imageToUIImage(_ image: Image) -> UIImage? {
        let controller = UIHostingController(rootView: image)
        let view = controller.view
        
        let renderer = UIGraphicsImageRenderer(size: view?.intrinsicContentSize ?? CGSize(width: 100, height: 100))
        return renderer.image { ctx in
            view?.drawHierarchy(in: CGRect(origin: .zero, size: view?.intrinsicContentSize ?? CGSize(width: 100, height: 100)), afterScreenUpdates: true)
        }
    }
    
    func saveImageToUserDefaults(image: UIImage) {
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            config.userProfileImageURL = imageData.base64EncodedString()
        }
    }
    
    
    
}

#Preview {
    EditUserView()
}
