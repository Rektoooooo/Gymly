//
//  Config.swift
//  Gymly
//
//  Created by Sebastián Kučera on 21.08.2024.
//

import Foundation
import SwiftData
import SwiftUI


class Config:ObservableObject {

    // MARK: - App Configuration Properties (not user-specific)
    
    @Published var daysRecorded: [String] {
        didSet {
            UserDefaults.standard.set(daysRecorded, forKey: "daysRecorded")
        }
    }
    
    @Published var splitStarted: Bool {
        didSet {
            UserDefaults.standard.set(splitStarted, forKey: "splitStarted")
        }
    }
    
    @Published var dayInSplit: Int {
        didSet {
            UserDefaults.standard.set(dayInSplit, forKey: "dayInSplit")
        }
    }
    
    @Published var splitLenght: Int {
        didSet {
            UserDefaults.standard.set(splitLenght, forKey: "splitLenght")
        }
    }
    
    @Published var lastUpdateDate: Date {
        didSet {
            UserDefaults.standard.set(lastUpdateDate, forKey: "lastUpdateDate")
        }
    }
    
    @Published var isUserLoggedIn: Bool {
        didSet {
            UserDefaults.standard.set(isUserLoggedIn, forKey: "isUserLoggedIn")
        }
    }
    
    
    @Published var firstSplitEdit: Bool {
        didSet {
            UserDefaults.standard.set(firstSplitEdit, forKey: "firstSplitEdit")
        }
    }
    
    @Published var activeExercise: Int {
        didSet {
            UserDefaults.standard.set(activeExercise, forKey: "activeExercise")
        }
    }
    
    @Published var graphDataValues: [Double] {
        didSet {
            UserDefaults.standard.set(graphDataValues, forKey: "graphDataValues")
        }
    }
    
    @Published var graphMaxValue: Double {
        didSet {
            UserDefaults.standard.set(graphMaxValue, forKey: "graphMaxValue")
        }
    }
    
    @Published var graphUpdatedExerciseIDs: Set<UUID> {
        didSet {
            let idsAsStrings = graphUpdatedExerciseIDs.map { $0.uuidString }
            UserDefaults.standard.set(idsAsStrings, forKey: "graphUpdatedExerciseIDs")
        }
    }
    

    @Published var totalWorkoutTimeMinutes: Int {
        didSet {
            UserDefaults.standard.set(totalWorkoutTimeMinutes, forKey: "totalWorkoutTimeMinutes")
        }
    }

    @Published var isCloudKitEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isCloudKitEnabled, forKey: "isCloudKitEnabled")
        }
    }

    @Published var cloudKitSyncDate: Date? {
        didSet {
            UserDefaults.standard.set(cloudKitSyncDate, forKey: "cloudKitSyncDate")
        }
    }
    
    @Published var isHealtKitEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isHealtKitEnabled, forKey: "isHealtKitEnabled")
        }
    }

    init() {
        self.daysRecorded = UserDefaults.standard.object(forKey: "daysRecorded") as? [String] ?? []
        self.splitStarted = UserDefaults.standard.object(forKey: "splitStarted") as? Bool ?? false
        self.dayInSplit = UserDefaults.standard.object(forKey: "dayInSplit") as? Int ?? 1
        self.splitLenght = UserDefaults.standard.object(forKey: "splitLenght") as? Int ?? 1
        self.lastUpdateDate = UserDefaults.standard.object(forKey: "lastUpdateDate")  as? Date ?? Date()
        self.isUserLoggedIn = UserDefaults.standard.object(forKey: "isUserLoggedIn") as? Bool ?? false
        self.firstSplitEdit = UserDefaults.standard.object(forKey: "firstSplitEdit") as? Bool ?? true
        self.activeExercise = UserDefaults.standard.object(forKey: "activeExercise") as? Int ?? 1
        self.graphDataValues = UserDefaults.standard.object(forKey: "graphDataValues") as? [Double] ?? []
        self.graphMaxValue = UserDefaults.standard.object(forKey: "graphMaxValue") as? Double ?? 1.0
        self.graphUpdatedExerciseIDs = UserDefaults.standard.object(forKey: "graphUpdatedExerciseIDs") as? Set<UUID> ?? []
        self.totalWorkoutTimeMinutes = UserDefaults.standard.object(forKey: "totalWorkoutTimeMinutes") as? Int ?? 0
        self.isCloudKitEnabled = UserDefaults.standard.object(forKey: "isCloudKitEnabled") as? Bool ?? false
        self.cloudKitSyncDate = UserDefaults.standard.object(forKey: "cloudKitSyncDate") as? Date
        self.isHealtKitEnabled = UserDefaults.standard.object(forKey: "isHealtKitEnabled") as? Bool ?? false
    }

}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
