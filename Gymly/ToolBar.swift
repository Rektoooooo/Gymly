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
            Group {
                ContentView()
                  .tabItem {
                    Label("Home", systemImage: "house")
                  }
                  .tag(1)

                if config.splitStarted {
                    TodayWorkoutView()
                        .tabItem {
                          Label("Routine", systemImage: "dumbbell")
                        }
                        .tag(2)
                } else {
                    SplitPopupView()
                        .tabItem {
                          Label("Routine", systemImage: "dumbbell")
                        }
                        .tag(2)
                }


                
                CalendarView()
                  .tabItem {
                    Label("Calendar", systemImage: "calendar")
                  }
                  .tag(3)
                
                SettingsView()
                  .tabItem {
                    Label("Settings", systemImage: "gear")
                  }
                  .tag(4)
                
            }
            .toolbar(.visible, for: .tabBar)
            .toolbarBackground(.black, for: .tabBar)
        }
        .environmentObject(config)
    }
    
}

struct SplitPopupView: View {
    @State var showSplit: Bool = false
    @State var showWholeSplit: Bool = false
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack {
            Text("U dident seted up your gym split yet.")
            Button("Set up split!") {
                showSplit.toggle()
            }
            .padding()
            .background(Color.graytint)
            .cornerRadius(20)
            .padding()
        }
        .sheet(isPresented: $showSplit, onDismiss: {
            showWholeSplit.toggle()
        }) {
            SetupSplitView()
                .presentationDetents([.fraction(0.4)])
        }
        .sheet(isPresented: $showWholeSplit, onDismiss: {
            
        }) {
            SplitView()
        }
    }
}


#Preview {
    ToolBar()
}
