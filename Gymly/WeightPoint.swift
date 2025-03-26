//
//  WeightPoint.swift
//  Gymly
//
//  Created by Sebastián Kučera on 26.03.2025.
//
import Foundation
import SwiftData

@Model
class WeightPoint {
    var date: Date
    var weight: Double
    
    init(date: Date, weight: Double) {
        self.date = date
        self.weight = weight
    }
}
