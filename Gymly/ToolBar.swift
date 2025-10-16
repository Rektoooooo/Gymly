//
//  ToolBar.swift
//  Gymly
//
//  Created by Sebastián Kučera on 13.05.2024.
//

import SwiftUI
import HealthKit
import SwiftData

struct ToolBar: View {
    @EnvironmentObject var config: Config
    @Environment(\.modelContext) private var context
    @State private var loginRefreshTrigger = false
    @StateObject private var userProfileManager = UserProfileManager.shared

    var body: some View {
        Group {
            if config.isUserLoggedIn {
                // Only show TabView when user is logged in
                TabView {
                    TodayWorkoutView(viewModel: WorkoutViewModel(config: config, context: context), loginRefreshTrigger: loginRefreshTrigger)
                        .tabItem {
                            Label("Routine", systemImage: "dumbbell")
                        }
                        .tag(1)

                    CalendarView(viewModel: WorkoutViewModel(config: config, context: context))
                        .tabItem {
                            Label("Calendar", systemImage: "calendar")
                        }
                        .tag(2)

                        .toolbar(.visible, for: .tabBar)
                        .toolbarBackground(.black, for: .tabBar)
                }
            } else {
                // Show sign-in view when not logged in
                SignInView(viewModel: WorkoutViewModel(config: config, context: context))
            }
        }
        .environmentObject(config)
        .environmentObject(userProfileManager)
        .task {
            // Initialize UserProfileManager with SwiftData context
            userProfileManager.setup(modelContext: context)

            // Load profile if user is already logged in (app reopen)
            if config.isUserLoggedIn {
                print("🔄 TOOLBAR: User already logged in, checking for existing profile...")

                // Try to load existing profile first
                let descriptor = FetchDescriptor<UserProfile>()
                let profiles = try? context.fetch(descriptor)

                if let existingProfile = profiles?.first {
                    // Profile exists in SwiftData - use it
                    userProfileManager.currentProfile = existingProfile
                    print("✅ TOOLBAR: Loaded existing profile for \(existingProfile.username)")
                } else {
                    // No local profile - try CloudKit first before creating default
                    print("🔍 TOOLBAR: No local profile found, checking CloudKit...")

                    if config.isCloudKitEnabled {
                        await userProfileManager.syncFromCloudKit()

                        if userProfileManager.currentProfile != nil {
                            print("✅ TOOLBAR: Restored profile from CloudKit")
                        } else {
                            // CloudKit had no data - create default profile
                            print("⚠️ TOOLBAR: No CloudKit data, creating default profile")
                            userProfileManager.loadOrCreateProfile()
                        }
                    } else {
                        // CloudKit not available - create default profile
                        print("⚠️ TOOLBAR: CloudKit not available, creating default profile")
                        userProfileManager.loadOrCreateProfile()
                    }
                }
            }
        }
    }


}
