//
//  GymlyApp.swift
//  Gymly
//
//  Created by Sebastián Kučera on 13.05.2024.
//

import SwiftUI

@main
struct GymlyApp: App {
    var body: some Scene {
        let config = Config(weightUnit: "Kg",splitStarted: false)
        WindowGroup {
            ToolBar()
                .environmentObject(config)
        }
        .modelContainer(for: [Exercise.self, Day.self, DayStorage.self])
    }
}
