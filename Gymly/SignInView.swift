//
//  SignInView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 28.01.2025.
//

import SwiftUI
import AuthenticationServices
import Foundation

struct SignInView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @EnvironmentObject var config: Config
    @EnvironmentObject var userProfileManager: UserProfileManager
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [.red, .pink]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                Circle()
                    .fill(ColorSchemeAdaptiveColor(light: .white, dark: .black))
                    .frame(width: 600, height: 600)
                VStack {
                    VStack{
                        Text("Gymly")
                            .bold()
                            .font(.largeTitle)
                            .foregroundStyle(ColorSchemeAdaptiveColor(light: .black, dark: .white))
                        Text("Track your workouts and progress")
                            .bold()
                            .foregroundStyle(ColorSchemeAdaptiveColor(light: .black, dark: .white))
                    }
                    VStack {
                        /// Sign in with apple id
                        SignInWithAppleButton(.signUp) { request in
                            request.requestedScopes = [.fullName, .email]
                        } onCompletion: { result in
                            switch result {
                            case .success(let authorization):
                                config.isUserLoggedIn = true
                                if let userCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                                    print("User ID: \(userCredential.user)")
                                    
                                    // Store email in UserProfile if available (but don't override existing)
                                    if let email = userCredential.email {
                                        print("User Email: \(email)")
                                        // Only update email if current profile doesn't have a valid email
                                        let currentEmail = userProfileManager.currentProfile?.email ?? ""
                                        if currentEmail.isEmpty || currentEmail == "user@example.com" {
                                            userProfileManager.updateEmail(email)
                                        }
                                    } else {
                                        print("Email not available (User has logged in before)")
                                    }

                                    // Store username from Apple ID, but only as fallback (will be overridden by CloudKit if available)
                                    if let fullName = userCredential.fullName,
                                       let givenName = fullName.givenName {
                                        print("🔥 APPLE ID USERNAME: \(givenName)")
                                        // Only update username if current profile has default username
                                        let currentUsername = userProfileManager.currentProfile?.username ?? ""
                                        if currentUsername.isEmpty || currentUsername == "User" {
                                            userProfileManager.updateUsername(givenName)
                                        }
                                    }
                                }
                                dismiss()

                                // Store the first-time login status outside the credential scope
                                let isFirstTimeLogin = (authorization.credential as? ASAuthorizationAppleIDCredential)?.fullName != nil
                                print("🔥 IS FIRST TIME LOGIN: \(isFirstTimeLogin)")

                                // Trigger CloudKit sync after successful login
                                Task {
                                    print("🔥 STARTING CLOUDKIT SYNC PROCESS")
                                    await CloudKitManager.shared.checkCloudKitStatus()

                                    // Set config iCloud sync state based on CloudKit availability
                                    await MainActor.run {
                                        config.isCloudKitEnabled = CloudKitManager.shared.isCloudKitEnabled
                                        print("🔥 CLOUDKIT MANAGER STATE: \(CloudKitManager.shared.isCloudKitEnabled)")
                                        print("🔥 CONFIG STATE: \(config.isCloudKitEnabled)")
                                        if CloudKitManager.shared.isCloudKitEnabled {
                                            print("🔥 CLOUDKIT IS ENABLED")
                                        } else {
                                            print("🔥 CLOUDKIT IS NOT AVAILABLE")
                                        }
                                    }

                                    if config.isCloudKitEnabled {
                                        print("🔥 STARTING USERPROFILE CLOUDKIT SYNC")

                                        // Try to fetch existing UserProfile from CloudKit
                                        await userProfileManager.syncFromCloudKit()

                                        print("🔥 USERPROFILE CLOUDKIT SYNC COMPLETED")
                                        print("🔥 CURRENT USERNAME: \(userProfileManager.currentProfile?.username ?? "none")")
                                    }

                                    // Post notification to refresh views
                                    await MainActor.run {
                                        NotificationCenter.default.post(name: Notification.Name.cloudKitDataSynced, object: nil)
                                    }
                                }

                            case .failure(let error):
                                print("Could not authenticate: \(error.localizedDescription)")
                            }
                        }
                        .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                        .frame(width: 200, height: 44)
                    }                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        }
    }
    
    func ColorSchemeAdaptiveColor(light: Color, dark: Color) -> Color {
        return Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light) })
    }
}
