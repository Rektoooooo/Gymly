//
//  ToolBar.swift
//  Gymly
//
//  Created by Sebastián Kučera on 13.05.2024.
//

import SwiftUI

struct ToolBar: View {
    
    @EnvironmentObject var config: Config
    @Environment(\.modelContext) private var context

    var body: some View {
        TabView {
                if config.splitStarted {
                    TodayWorkoutView(viewModel: WorkoutViewModel(config: config, context: context))
                        .tabItem {
                          Label("Routine", systemImage: "dumbbell")
                        }
                        .tag(1)
                } else {
                    SplitPopupView(viewModel: WorkoutViewModel(config: config, context: context))
                        .tabItem {
                            Label("Routine", systemImage: "dumbbell")
                        }
                        .tag(1)
                }
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
        )) {
            SignInView()
        }
        .environmentObject(config)
    }
    
}
