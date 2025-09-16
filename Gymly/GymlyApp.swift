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
        let config = Config(weightUnit: "Kg",splitStarted: false, daysRecorded: [],dayInSplit: 0, lastUpdateDate: Date(), splitLenght: 0, isUserLoggedIn: false, userProfileImageURL: "defaultProfileImage",username: "User",userEmail: "user@gmail.com", allowdateOfBirth: false, allowHeight: false, allowWeight: false, isHealthEnabled: false, roundSetWeights: false, firstSplitEdit: true, activeExercise: 1, graphDataValues: [], graphMaxValue: 1.0, graphUpdatedExercisesIDs: [], userWeight: 0.0, userBMI: 0.0, userHeight: 0.0, userAge: 0, totalWorkoutTimeMinutes: 0)
        WindowGroup {
            ToolBar()
                .environmentObject(config)
                .onOpenURL { url in
                    handleIncomingFile(url, config: config)
                }
        }
        .modelContainer(for: [Exercise.self, Day.self, DayStorage.self, WeightPoint.self])
    }
    
    private func handleIncomingFile(_ url: URL, config: Config) {
        print("Opened file: \(url)")

        if let modelContainer = try? ModelContainer(for: Exercise.self, Day.self, DayStorage.self) {
            let context = modelContainer.mainContext
            let viewModel = WorkoutViewModel(config: config, context: context)
            
            if let split = viewModel.importSplit(from: url) {
                print("✅ Successfully decoded split: \(split.name)") // Debug log
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .importSplit, object: split)
                    print("📢 Notification posted for imported split")
                }
            } else {
                print("❌ Failed to decode split")
            }
        }
    }
}

extension Notification.Name {
    static let importSplit = Notification.Name("importSplit")
}
