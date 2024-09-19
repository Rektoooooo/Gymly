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
    
    @Published var splitStarted: Bool {
        didSet {
            UserDefaults.standard.set(splitStarted, forKey: "splitStarted")
        }
    }
    
    init(weightUnit: String, splitStarted: Bool) {
        self.weightUnit = UserDefaults.standard.object(forKey: "weightUnit") as? String ?? "Kg"
        self.splitStarted = UserDefaults.standard.object(forKey: "splitStarted") as? Bool ?? false
    }
}
