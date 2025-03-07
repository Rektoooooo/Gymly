//
//  SignInView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 28.01.2025.
//

import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @EnvironmentObject var config: Config
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
                                    
                                    if let email = userCredential.email {
                                        print("User Email: \(email)")
                                        config.userEmail = email
                                        UserDefaults.standard.set(email, forKey: "userEmail")
                                    } else {
                                        print("Email not available (User has logged in before)")
                                        if let savedEmail = UserDefaults.standard.string(forKey: "userEmail") {
                                            config.userEmail = savedEmail
                                            print("Loaded saved email: \(savedEmail)")
                                        }
                                    }

                                    if let fullName = userCredential.fullName {
                                        print("User Full Name: \(fullName)")
                                    }
                                }
                                dismiss()
                                
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
