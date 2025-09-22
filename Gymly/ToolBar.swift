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
        .sheet(isPresented: Binding(
            get: { !config.isUserLoggedIn },
            set: { newValue in config.isUserLoggedIn = !newValue }
        ), onDismiss: {
            // When SignInView dismisses (after login), give CloudKit a moment to sync then refresh profile
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                print("🖼️ SIGNIN DISMISS: Triggering profile refresh after login")
                loginRefreshTrigger.toggle()
            }
        }) {
            SignInView(viewModel: WorkoutViewModel(config: config, context: context))
        }
        .onChange(of: config.isUserLoggedIn) { oldValue, newValue in
            if newValue == true {
                // User just logged in, trigger refresh
                loginRefreshTrigger.toggle()
                userProfileManager.loadOrCreateProfile()
            }
        }
        .environmentObject(config)
        .environmentObject(userProfileManager)
        .onAppear {
            // Initialize UserProfileManager with SwiftData context
            userProfileManager.setup(modelContext: context)
        }
    }


}
