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
    
    @Published var weightUnit: String {
        didSet {
            UserDefaults.standard.set(weightUnit, forKey: "weightUnit")
        }
    }
    
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
    
    @Published var userProfileImageURL: String? {
        didSet {
            UserDefaults.standard.set(userProfileImageURL, forKey: "userProfileImageURL")
        }
    }
    
    @Published var username: String {
        didSet {
            UserDefaults.standard.set(username, forKey: "username")
        }
    }
    
    @Published var userEmail: String {
        didSet {
            UserDefaults.standard.set(userEmail, forKey: "userEmail")
        }
    }
   
    @Published var allowDateOfBirth: Bool {
        didSet {
            UserDefaults.standard.set(allowDateOfBirth, forKey: "allowDateOfBirth")
        }
    }
    
    @Published var allowHeight: Bool {
        didSet {
            UserDefaults.standard.set(allowHeight, forKey: "allowHeight")
        }
    }
    
    @Published var allowWeight: Bool {
        didSet {
            UserDefaults.standard.set(allowWeight, forKey: "allowWeight")
        }
    }
    
    @Published var isHealthEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isHealthEnabled, forKey: "isHealthEnabled")
        }
    }
    
    @Published var roundSetWeights: Bool {
        didSet {
            UserDefaults.standard.set(roundSetWeights, forKey: "roundSetWeights")
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
    
    @Published var userWeight: Double {
        didSet {
            UserDefaults.standard.set(userWeight, forKey: "userWeight")
        }
    }
    
    @Published var userBMI: Double {
        didSet {
            UserDefaults.standard.set(userBMI, forKey: "userBMI")
        }
    }
    
    @Published var userHeight: Double {
        didSet {
            UserDefaults.standard.set(userHeight, forKey: "userHeight")
        }
    }
    
    @Published var userAge: Int {
        didSet {
            UserDefaults.standard.set(userAge, forKey: "userAge")
        }
    }
    
    init(weightUnit: String, splitStarted: Bool, daysRecorded: [String], dayInSplit: Int, lastUpdateDate: Date, splitLenght: Int, isUserLoggedIn: Bool,userProfileImageURL: String?,username: String, userEmail: String, allowdateOfBirth: Bool, allowHeight: Bool, allowWeight: Bool, isHealthEnabled: Bool, roundSetWeights: Bool, firstSplitEdit:Bool, activeExercise: Int, graphDataValues: [Double], graphMaxValue: Double, graphUpdatedExercisesIDs: Set<UUID>, userWeight: Double, userBMI: Double, userHeight: Double, userAge: Int) {
        self.weightUnit = UserDefaults.standard.object(forKey: "weightUnit") as? String ?? "Kg"
        self.splitStarted = UserDefaults.standard.object(forKey: "splitStarted") as? Bool ?? false
        self.daysRecorded = UserDefaults.standard.object(forKey: "daysRecorded") as? [String] ?? []
        self.dayInSplit = UserDefaults.standard.object(forKey: "dayInSplit") as? Int ?? 1
        self.splitLenght = UserDefaults.standard.object(forKey: "splitLenght") as? Int ?? 1
        self.lastUpdateDate = UserDefaults.standard.object(forKey: "lastUpdateDate")  as? Date ?? Date()
        self.isUserLoggedIn = UserDefaults.standard.object(forKey: "isUserLoggedIn") as? Bool ?? false
        self.userProfileImageURL = UserDefaults.standard.object(forKey: "userProfileImageURL") as? String ?? "defaultProfileImage"
        self.username = UserDefaults.standard.object(forKey: "username") as? String ?? "User"
        self.userEmail = UserDefaults.standard.object(forKey: "userEmail") as? String ?? "user@example.com"
        self.allowDateOfBirth = UserDefaults.standard.object(forKey: "allowDateOfBirth") as? Bool ?? false
        self.allowHeight = UserDefaults.standard.object(forKey: "allowHeight") as? Bool ?? false
        self.allowWeight = UserDefaults.standard.object(forKey: "allowWeight") as? Bool ?? false
        self.isHealthEnabled = UserDefaults.standard.object(forKey: "isHealthEnabled") as? Bool ?? false
        self.roundSetWeights = UserDefaults.standard.object(forKey: "roundSetWeights") as? Bool ?? false
        self.firstSplitEdit = UserDefaults.standard.object(forKey: "firstSplitEdit") as? Bool ?? true
        self.activeExercise = UserDefaults.standard.object(forKey: "activeExercise") as? Int ?? 1
        self.graphDataValues = UserDefaults.standard.object(forKey: "graphDataValues") as? [Double] ?? []
        self.graphMaxValue = UserDefaults.standard.object(forKey: "graphMaxValue") as? Double ?? 1.0
        self.graphUpdatedExerciseIDs = UserDefaults.standard.object(forKey: "graphUpdatedExerciseIDs") as? Set<UUID> ?? []
        self.userWeight = UserDefaults.standard.object(forKey: "userWeight") as? Double ?? 0.0
        self.userBMI = UserDefaults.standard.object(forKey: "userBMI") as? Double ?? 0.0
        self.userHeight = UserDefaults.standard.object(forKey: "userHeight") as? Double ?? 0.0
        self.userAge = UserDefaults.standard.object(forKey: "userAge") as? Int ?? 0
    }
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
