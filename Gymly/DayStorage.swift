//
//  DayStorage.swift
//  Gymly
//
//  Created by Sebastián Kučera on 29.08.2024.
//

import Foundation
import SwiftData

@Model
class DayStorage {
    var id: UUID
    var day: Day
    var date: Date
    
    init(id: UUID, day: Day, date: Date) {
        self.id = id
        self.day = day
        self.date = date
    }
}
