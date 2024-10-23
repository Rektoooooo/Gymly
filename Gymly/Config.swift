//
//  Config.swift
//  Gymly
//
//  Created by Sebastián Kučera on 21.08.2024.
//

import Foundation
import SwiftData


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
    
    init(weightUnit: String, splitStarted: Bool, daysRecorded: [String], dayInSplit: Int, lastUpdateDate: Date, splitLenght: Int) {
        self.weightUnit = UserDefaults.standard.object(forKey: "weightUnit") as? String ?? "Kg"
        self.splitStarted = UserDefaults.standard.object(forKey: "splitStarted") as? Bool ?? false
        self.daysRecorded = UserDefaults.standard.object(forKey: "daysRecorded") as? [String] ?? []
        self.dayInSplit = UserDefaults.standard.object(forKey: "dayInSplit") as? Int ?? 1
        self.splitLenght = UserDefaults.standard.object(forKey: "splitLenght") as? Int ?? 1
        self.lastUpdateDate = UserDefaults.standard.object(forKey: "lastUpdateDate")  as? Date ?? Date()
    }
}
