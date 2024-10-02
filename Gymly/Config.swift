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
    
    init(weightUnit: String, splitStarted: Bool, daysRecorded: [String]) {
        self.weightUnit = UserDefaults.standard.object(forKey: "weightUnit") as? String ?? "Kg"
        self.splitStarted = UserDefaults.standard.object(forKey: "splitStarted") as? Bool ?? false
        self.daysRecorded = UserDefaults.standard.object(forKey: "daysRecorded") as? [String] ?? []
    }
}
