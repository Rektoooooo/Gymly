//
//  ToolBar.swift
//  Gymly
//
//  Created by Sebastián Kučera on 13.05.2024.
//

import SwiftUI

struct ToolBar: View {
    
    @EnvironmentObject var config: Config
    @State private var weekDays:[String] = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
    @Environment(\.modelContext) private var context

    var body: some View {
        TabView {
            Group {
                ContentView()
                  .tabItem {
                    Label("Home", systemImage: "house")
                  }
                  .tag(1)

                TodayWorkoutView()
                  .tabItem {
                    Label("Routine", systemImage: "dumbbell")
                  }
                  .tag(2)
                
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
            .onAppear() {
                if !config.splitStarted {
                    for i in 0...6 {
                        addDay(name: weekDays[i])
                    }
                    do {
                        try context.save()
                        debugPrint("Context saved")
                    } catch {
                        debugPrint(error)
                    }
                }
            }
            .toolbar(.visible, for: .tabBar)
            .toolbarBackground(.black, for: .tabBar)
        }
        .environmentObject(config)
    }
    
    func addDay(name: String) {
        context.insert(Day(name: name,dayOfWeek: name, exercises: []))
        debugPrint("Added day \(name)")
        config.splitStarted = true
    }
    
    
}


#Preview {
    ToolBar()
}
