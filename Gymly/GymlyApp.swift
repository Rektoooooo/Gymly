//
//  GymlyApp.swift
//  Gymly
//
//  Created by Sebastián Kučera on 13.05.2024.
//

import SwiftUI
import SwiftData

@main
struct GymlyApp: App {
    var body: some Scene {
        let config = Config()
        WindowGroup {
            ToolBar()
                .environmentObject(config)
                .onOpenURL { url in
                    handleIncomingFile(url, config: config)
                }
        }
        .modelContainer(for: [Split.self, Exercise.self, Day.self, DayStorage.self, WeightPoint.self, UserProfile.self])
    }
    
    private func handleIncomingFile(_ url: URL, config: Config) {
        print("Opened file: \(url)")

        if let modelContainer = try? ModelContainer(for: Split.self, Exercise.self, Day.self, DayStorage.self, WeightPoint.self, UserProfile.self) {
            let context = modelContainer.mainContext
            let viewModel = WorkoutViewModel(config: config, context: context)
            
            if let split = viewModel.importSplit(from: url) {
                print("✅ Successfully decoded split: \(split.name)") // Debug log
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .importSplit, object: split)
                    print("📢 Notification posted for imported split")

                    // Also post cloudKitDataSynced to refresh any other views
                    NotificationCenter.default.post(name: .cloudKitDataSynced, object: nil)
                    print("📢 CloudKit sync notification posted")
                }
            } else {
                print("❌ Failed to decode split")
            }
        }
    }
}

extension Notification.Name {
    static let importSplit = Notification.Name("importSplit")
    static let cloudKitDataSynced = Notification.Name("cloudKitDataSynced")
}
