//
//  ToolBar.swift
//  Gymly
//
//  Created by Sebastián Kučera on 13.05.2024.
//

import SwiftUI
import HealthKit

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
        .onAppear {
            // Initialize UserProfileManager with SwiftData context
            userProfileManager.setup(modelContext: context)

            // Load profile if user is already logged in (app reopen)
            if config.isUserLoggedIn {
                userProfileManager.loadOrCreateProfile()
                print("🔄 TOOLBAR: Loaded existing profile on app reopen")
            }
        }
    }


}
