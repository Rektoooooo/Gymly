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
        let config = Config(weightUnit: "Kg",splitStarted: false, daysRecorded: [],dayInSplit: 0, lastUpdateDate: Date(), splitLenght: 0, isUserLoggedIn: false, userProfileImageURL: "defaultProfileImage",username: "User",userEmail: "user@gmail.com", allowdateOfBirth: false, allowHeight: false, allowWeight: false, isHealthEnabled: false, roundSetWeights: false, firstSplitEdit: true)
        WindowGroup {
            ToolBar()
                .environmentObject(config)
            
            
        }
        .modelContainer(for: [Exercise.self, Day.self, DayStorage.self])
    }
}
